# VS Code Configuration for Bling Project

This directory contains VS Code workspace configuration for the Bling project.

## V8 Memory Configuration

### For Extension Host (VS Code itself)

To increase memory for the VS Code extension host (which helps with large Flutter projects), you need to modify VS Code's `argv.json` file:

#### On macOS/Linux:
1. Open VS Code
2. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Linux)
3. Type "Configure Runtime Arguments"
4. Add or modify the following line:
   ```json
   "js-flags": "--max-old-space-size=4096"
   ```
5. Restart VS Code

The `argv.json` file location:
- **macOS**: `~/Library/Application Support/Code/User/argv.json`
- **Linux**: `~/.config/Code/User/argv.json`
- **Windows**: `%APPDATA%\Code\User\argv.json`

#### Example argv.json:
```json
{
  // Increase V8 old space (applies to renderer/extension host)
  "js-flags": "--max-old-space-size=4096",
  "disable-hardware-acceleration": false
}
```

### For Node.js Debugging

The `launch.json` file in this directory already includes V8 memory configuration for debugging Node.js functions:
- Firebase Functions debugging uses `--max-old-space-size=4096`
- Firebase Emulator uses `NODE_OPTIONS=--max-old-space-size=4096`

### For Firebase Functions Development

The `functions-v2/package.json` has been updated to include `NODE_OPTIONS` for the `serve` and `shell` scripts.

## Files in this Directory

- **settings.json**: Workspace settings for Flutter development, file watching, and search exclusions
- **launch.json**: Debug configurations for Flutter app and Firebase Functions
- **extensions.json**: Recommended VS Code extensions for this project
- **README.md**: This documentation file

## Recommended Extensions

This project recommends the following VS Code extensions:
- Dart
- Flutter
- ESLint
- Code Spell Checker
- Prettier

These will be automatically suggested when you open this workspace in VS Code.

## Performance Tips

1. **Exclude build directories**: The `settings.json` excludes common build directories from file watching and search to improve performance.
2. **Increase memory**: If you experience slowness or crashes, increase the `--max-old-space-size` value in `argv.json`.
3. **Close unused tabs**: Keep only necessary files open to reduce memory usage.
4. **Disable unused extensions**: Disable extensions you don't need for this project.

## Troubleshooting

### VS Code is slow or crashes
- Increase the memory in `argv.json` (try 8192 for 8GB)
- Exclude more directories in `settings.json` under `files.watcherExclude`
- Disable source control for large repositories temporarily

### Firebase Functions debugging not working
- Ensure Node.js 20 is installed (check `node --version`)
- Verify the `functions-v2` directory exists
- Check that Firebase CLI is installed (`firebase --version`)

### Flutter debugging issues
- Ensure Flutter SDK is properly installed
- Run `flutter doctor` to check for issues
- Update the `dart.flutterSdkPath` in `settings.json` if needed
