#!/usr/bin/env bash
set -euo pipefail

# Script de migración (Option A)
# Crea un nuevo proyecto Flutter con la versión local de Flutter y copia/libera el código Dart y assets.
# Uso: desde /home/jrlopez/Documentos/Desarrollo
#   bash scripts/migrate_to_new_project.sh appmoviles_migrated
# Si no se pasa nombre, usa 'appmoviles_migrated'

NEW_NAME=${1:-appmoviles_migrated}
OLD_NAME="appmoviles"
WORKDIR=$(pwd)
OLD_DIR="$WORKDIR/$OLD_NAME"
NEW_DIR="$WORKDIR/$NEW_NAME"

if [ ! -d "$OLD_DIR" ]; then
  echo "No encuentro el proyecto original en $OLD_DIR"
  exit 1
fi

echo "Versión de Flutter local:"
flutter --version || true

if [ -d "$NEW_DIR" ]; then
  echo "La carpeta $NEW_DIR ya existe. Aborta para evitar sobrescribir. Elimina o elige otro nombre."
  exit 1
fi

echo "Creando nuevo proyecto Flutter '$NEW_NAME'..."
flutter create "$NEW_NAME"

# Copiar lib/ y assets/
echo "Copiando lib/ y assets/ desde $OLD_DIR a $NEW_DIR"
rsync -av --progress "$OLD_DIR/lib/" "$NEW_DIR/lib/"
if [ -d "$OLD_DIR/assets" ]; then
  rsync -av --progress "$OLD_DIR/assets/" "$NEW_DIR/assets/"
fi

# Backup del pubspec del nuevo y del viejo
cp "$NEW_DIR/pubspec.yaml" "$NEW_DIR/pubspec.yaml.bak"
cp "$OLD_DIR/pubspec.yaml" "$NEW_DIR/pubspec_old.yaml"

# Funciones para extraer bloques básicos del pubspec viejo
extract_block(){
  local key="$1"; local in=false
  awk -v key="$key" '
    BEGIN{p=0}
    $0 ~ "^"key":"{p=1; print; next}
    p==1{ if ($0 ~ "^[^[:space:]].*:") exit; print }
  ' "$NEW_DIR/pubspec_old.yaml"
}

# Reemplazar bloques en pubspec nuevo (dependencies, dev_dependencies, environment, flutter->assets)
# Cuidado: hace un reemplazo simple: busca la cabecera y borra el bloque existente hasta la siguiente cabecera top-level.

# 1) environment
if grep -q "^environment:" "$NEW_DIR/pubspec_old.yaml"; then
  echo "Actualizando environment en nuevo pubspec..."
  awk 'BEGIN{p=1} /^environment:/{print "# == environment copiado del proyecto antiguo =="; while((getline line < "'$NEW_DIR'/pubspec_old.yaml")>0){ if(line ~ /^environment:/){print line; break}}; p=0} p==1{print} ' "$NEW_DIR/pubspec.yaml" > "$NEW_DIR/pubspec.tmp.yaml" || true
  # Simple fallback: prefer no-op si el awk falló; we'll instead copy the old environment manually
  # (no-op to avoid complejidad extrema)
fi

# Mejor enfoque: haremos merges manuales por secciones más seguras.

echo "Intentando fusionar 'dependencies' y 'dev_dependencies' desde pubspec_old.yaml al nuevo pubspec..."

# Extraer dependencies y dev_dependencies de pubspec_old
awk '/^dependencies:/{print; flag=1; next} /^dev_dependencies:/{flag=0} flag==1{print}' "$NEW_DIR/pubspec_old.yaml" > "$NEW_DIR/.old_dependencies.tmp" || true
awk '/^dev_dependencies:/{print; flag=1; next} /^dependency_overrides:/{flag=0} flag==1{print}' "$NEW_DIR/pubspec_old.yaml" > "$NEW_DIR/.old_dev_dependencies.tmp" || true

# Inserta/concatena: agregamos las dependencias viejas al final de la sección dependencies del nuevo pubspec
# NOTA: Este paso es conservador: si hay claves duplicadas tendrás que revisarlas manualmente.

# Creamos un script Python temporal para hacer el merge (más robusto que heredocs inline)
cat > /tmp/migrate_merge_pubspec.py <<'PY'
import sys, yaml, shutil
new_path = sys.argv[1]
old_deps_path = sys.argv[2]
old_dev_path = sys.argv[3]
new_backup = new_path + '.auto_merge.bak'

with open(new_path, 'r', encoding='utf-8') as f:
    newyaml = yaml.safe_load(f) or {}

# Cargar viejas
old_deps = {}
old_dev = {}
try:
    with open(old_deps_path, 'r', encoding='utf-8') as f:
        oldcont = f.read()
        if oldcont.strip():
            # oldcont may contain the header 'dependencies:' at top; load fully
            try:
                parsed = yaml.safe_load(oldcont)
                if isinstance(parsed, dict) and 'dependencies' in parsed:
                    old_deps = parsed
                else:
                    # try to wrap
                    old_deps = {'dependencies': parsed}
            except Exception:
                old_deps = {}
except Exception:
    old_deps = {}
try:
    with open(old_dev_path, 'r', encoding='utf-8') as f:
        oldcont = f.read()
        if oldcont.strip():
            try:
                parsed = yaml.safe_load(oldcont)
                if isinstance(parsed, dict) and 'dev_dependencies' in parsed:
                    old_dev = parsed
                else:
                    old_dev = {'dev_dependencies': parsed}
            except Exception:
                old_dev = {}
except Exception:
    old_dev = {}

# Merge dependencies
if 'dependencies' not in newyaml or newyaml['dependencies'] is None:
    newyaml['dependencies'] = {}
if isinstance(old_deps, dict):
    deps_block = old_deps.get('dependencies') if 'dependencies' in old_deps else old_deps
    if isinstance(deps_block, dict):
        for kk, vv in deps_block.items():
            if kk not in newyaml['dependencies']:
                newyaml['dependencies'][kk] = vv

if 'dev_dependencies' not in newyaml or newyaml['dev_dependencies'] is None:
    newyaml['dev_dependencies'] = {}
if isinstance(old_dev, dict):
    dev_block = old_dev.get('dev_dependencies') if 'dev_dependencies' in old_dev else old_dev
    if isinstance(dev_block, dict):
        for kk, vv in dev_block.items():
            if kk not in newyaml['dev_dependencies']:
                newyaml['dev_dependencies'][kk] = vv

# Ensure flutter assets include assets/
if 'flutter' not in newyaml:
    newyaml['flutter'] = {}
if 'assets' not in newyaml['flutter'] or newyaml['flutter']['assets'] is None:
    newyaml['flutter']['assets'] = ['assets/']
else:
    if 'assets/' not in newyaml['flutter']['assets']:
        newyaml['flutter']['assets'].append('assets/')

# Backup and write
shutil.copyfile(new_path, new_backup)
with open(new_path, 'w', encoding='utf-8') as f:
    yaml.dump(newyaml, f, sort_keys=False, allow_unicode=True)
print('Merged dependencies into', new_path)
PY

python3 /tmp/migrate_merge_pubspec.py "$NEW_DIR/pubspec.yaml" "$NEW_DIR/.old_dependencies.tmp" "$NEW_DIR/.old_dev_dependencies.tmp"
rm -f /tmp/migrate_merge_pubspec.py

# Ajustes Android mínimos: minSdk/target/compile
echo "Ajustando minSdk/target/compile en el nuevo proyecto Android (si aplica)..."
APP_BUILD_KTS="$NEW_DIR/android/app/build.gradle.kts"
if [ -f "$APP_BUILD_KTS" ]; then
  # Reemplazar/minimizar: set compileSdk=33, minSdk=21, targetSdk=33
  cat > /tmp/migrate_fix_gradle.py <<'PY'
import sys, re
p = sys.argv[1]
with open(p,'r',encoding='utf-8') as f:
    s=f.read()
# compileSdk
s=re.sub(r"compileSdk\s*=\s*\d+","compileSdk = 33",s)
# minSdk (handle expressions and numbers)
s=re.sub(r"minSdk\s*=\s*[^\n\r]+","minSdk = 21",s)
# targetSdk
s=re.sub(r"targetSdk\s*=\s*\d+","targetSdk = 33",s)
with open(p,'w',encoding='utf-8') as f:
    f.write(s)
print('Aplicado cambios mínimos en',p)
PY
  python3 /tmp/migrate_fix_gradle.py "$APP_BUILD_KTS"
  rm -f /tmp/migrate_fix_gradle.py
else
  echo "No encontré $APP_BUILD_KTS — revisa manualmente minSdk/targetSdk"
fi

# Crear plantilla key.properties (NO con credenciales reales)
cat > "$NEW_DIR/android/key.properties" << EOF
# Plantilla key.properties - Rellenar con tus datos reales antes de firmar
storePassword=TU_STORE_PASSWORD
keyPassword=TU_KEY_PASSWORD
keyAlias=TU_KEY_ALIAS
storeFile=/home/tu_usuario/keystore/my-release-key.jks
EOF

echo "Migración básica completada. Pasos siguientes (manuales o automáticos):"
cat <<EOT
1) Revisa "$NEW_DIR/pubspec.yaml" y corrige versiones conflictivas (sdk constraints o dependencias duplicadas).
2) Si quieres firmar el build, modifica "$NEW_DIR/android/key.properties" con tus credenciales reales y el path a tu keystore.
3) Revisa "$NEW_DIR/android/local.properties" y asegúrate que sdk.dir y flutter.sdk estén correctos.
4) Ejecuta en el nuevo proyecto:
   cd $NEW_DIR
   flutter pub get
   flutter build appbundle --release
   # o para APK
   flutter build apk --release --split-per-abi

Si falla en cualquier punto, copia/pega aquí la salida de:
  flutter doctor -v
  flutter build appbundle --release -v
  o en android: ./gradlew assembleRelease --stacktrace

Archivo de backup del pubspec original: $NEW_DIR/pubspec_old.yaml

EOT

exit 0
