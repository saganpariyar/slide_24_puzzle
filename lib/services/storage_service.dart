import 'dart:convert';
import 'storage_backend.dart';

class StorageService {
  static const String _saveFile = 'slide_24_puzzle_v1.json';

  static int profileIndex = 0;
  static int trayThemeIndex = 0;
  static int backgroundIndex = 0;
  static int gridSizeIndex = 2; // default 5x5 (24-Puzzle)
  static int gamesWon = 0;
  static final Map<int, int> bestMovesBySize = {};
  static final Map<int, int> bestSecondsBySize = {};

  static Future<void> init() async {
    final raw = await readSaveJson(_saveFile);
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      profileIndex = (data['profileIndex'] as int? ?? 0).clamp(0, 3);
      trayThemeIndex = (data['trayThemeIndex'] as int? ?? 0).clamp(0, 3);
      backgroundIndex = (data['backgroundIndex'] as int? ?? 0).clamp(0, 3);
      gridSizeIndex = (data['gridSizeIndex'] as int? ?? 2).clamp(0, 3);
      gamesWon = data['gamesWon'] as int? ?? 0;

      final bm = data['bestMovesBySize'] as Map<String, dynamic>?;
      if (bm != null) {
        for (final e in bm.entries) {
          final k = int.tryParse(e.key);
          if (k != null) bestMovesBySize[k] = e.value as int;
        }
      }
      final bs = data['bestSecondsBySize'] as Map<String, dynamic>?;
      if (bs != null) {
        for (final e in bs.entries) {
          final k = int.tryParse(e.key);
          if (k != null) bestSecondsBySize[k] = e.value as int;
        }
      }
    } catch (_) {}
  }

  static Future<void> save() async {
    final payload = <String, dynamic>{
      'profileIndex': profileIndex,
      'trayThemeIndex': trayThemeIndex,
      'backgroundIndex': backgroundIndex,
      'gridSizeIndex': gridSizeIndex,
      'gamesWon': gamesWon,
      'bestMovesBySize': bestMovesBySize.map((k, v) => MapEntry(k.toString(), v)),
      'bestSecondsBySize': bestSecondsBySize.map((k, v) => MapEntry(k.toString(), v)),
    };
    await writeSaveJson(_saveFile, jsonEncode(payload));
  }
}

