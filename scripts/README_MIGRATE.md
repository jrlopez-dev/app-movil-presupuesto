# Migración a nuevo proyecto Flutter (Option A)

Este README describe cómo usar `migrate_to_new_project.sh` para crear un nuevo proyecto Flutter con la versión de Flutter instalada y migrar tu código `lib/` y `assets/`.

Uso rápido:

1. Abre una terminal en `/home/jrlopez/Documentos/Desarrollo` (el script asume que `appmoviles` está en esta carpeta).

2. Ejecuta:

```bash
bash scripts/migrate_to_new_project.sh appmoviles_migrated
```

3. Revisa los archivos generados en `appmoviles_migrated/`:
   - `pubspec.yaml` (fusionado parcialmente)
   - `lib/` y `assets/` copiados
   - `android/` generado por Flutter con ajustes mínimos aplicados
   - `android/key.properties` (plantilla) — NO subas este archivo al VCS

4. Ejecuta desde el nuevo proyecto:

```bash
cd appmoviles_migrated
flutter pub get
flutter build appbundle --release
```

5. Si el build falla, usa:

```bash
cd android
./gradlew assembleRelease --stacktrace --info > ~/migration_gradle_log.txt 2>&1
```

Adjunta `migration_gradle_log.txt` o pega su contenido aquí para que lo revise.

Notas:
- El script intenta fusionar las dependencias automáticamente, pero debes revisar manualmente `pubspec.yaml` si hay conflictos.
- Asegúrate de tener JDK 17 instalado y `JAVA_HOME` configurado (recomendado por compatibilidad con Kotlin y Gradle).
- Revisa y corrige `android/local.properties` (ruta del Android SDK) y `android/key.properties` (keystore) antes de compilar en release.
