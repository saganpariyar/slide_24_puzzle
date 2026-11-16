import 'package:flutter/material.dart';

class PlayerProfileOption {
  final String id;
  final String name;
  final String title;
  final String assetPath;
  final Color accentColor;

  const PlayerProfileOption({
    required this.id,
    required this.name,
    required this.title,
    required this.assetPath,
    required this.accentColor,
  });
}

class TrayThemeOption {
  final String id;
  final String name;
  final String subtitle;
  final Color trayOuter;
  final Color trayInner;
  final Color tileTop;
  final Color tileBottom;
  final Color tileBorder;
  final Color textColor;
  final Color solvedGlow;

  const TrayThemeOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.trayOuter,
    required this.trayInner,
    required this.tileTop,
    required this.tileBottom,
    required this.tileBorder,
    required this.textColor,
    required this.solvedGlow,
  });
}

class StudioBackgroundOption {
  final String id;
  final String name;
  final String subtitle;
  final String assetPath;
  final Color accentColor;

  const StudioBackgroundOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.assetPath,
    required this.accentColor,
  });
}

class BoardModeOption {
  final int gridSize;
  final String label;
  final String subtitle;

  const BoardModeOption({
    required this.gridSize,
    required this.label,
    required this.subtitle,
  });
}

class SlideCustomization {
  static const List<PlayerProfileOption> profiles = [
    PlayerProfileOption(
      id: 'aero_wisp',
      name: 'Aero-Wisp',
      title: 'Speed Tactician',
      assetPath: 'assets/images/profiles/light_aero_wisp.png',
      accentColor: Color(0xFF38BDF8),
    ),
    PlayerProfileOption(
      id: 'volt_sprite',
      name: 'Volt-Sprite',
      title: 'Logic Sprinter',
      assetPath: 'assets/images/profiles/light_volt_sprite.png',
      accentColor: Color(0xFF34D399),
    ),
    PlayerProfileOption(
      id: 'solar_falcon',
      name: 'Solar-Falcon',
      title: 'Master Solver',
      assetPath: 'assets/images/profiles/light_solar_falcon.png',
      accentColor: Color(0xFFFBBF24),
    ),
    PlayerProfileOption(
      id: 'nebula_lynx',
      name: 'Nebula-Lynx',
      title: 'Grandmaster',
      assetPath: 'assets/images/profiles/light_nebula_lynx.png',
      accentColor: Color(0xFFE879F9),
    ),
  ];

  static const List<TrayThemeOption> trayThemes = [
    TrayThemeOption(
      id: 'sandwood',
      name: 'Classic Sandwood',
      subtitle: 'Carved Beech & Crimson',
      trayOuter: Color(0xFFDAB179),
      trayInner: Color(0xFF8E5E2D),
      tileTop: Color(0xFFF5DBB3),
      tileBottom: Color(0xFFD5A86E),
      tileBorder: Color(0xFFA47542),
      textColor: Color(0xFF7F1D1D),
      solvedGlow: Color(0xFF16A34A),
    ),
    TrayThemeOption(
      id: 'obsidian_cyber',
      name: 'Obsidian Cyber',
      subtitle: 'Dark Slate & Neon Cyan',
      trayOuter: Color(0xFF1E293B),
      trayInner: Color(0xFF090D1A),
      tileTop: Color(0xFF1E293B),
      tileBottom: Color(0xFF0F172A),
      tileBorder: Color(0xFF38BDF8),
      textColor: Color(0xFF38BDF8),
      solvedGlow: Color(0xFF34D399),
    ),
    TrayThemeOption(
      id: 'royal_jade',
      name: 'Royal Emerald',
      subtitle: 'Jade Stone & Gold',
      trayOuter: Color(0xFF065F46),
      trayInner: Color(0xFF022C22),
      tileTop: Color(0xFF10B981),
      tileBottom: Color(0xFF047857),
      tileBorder: Color(0xFFFBBF24),
      textColor: Color(0xFFFEF08A),
      solvedGlow: Color(0xFFFBBF24),
    ),
    TrayThemeOption(
      id: 'crimson_ivory',
      name: 'Ivory & Walnut',
      subtitle: 'Lacquer Cream & Ruby',
      trayOuter: Color(0xFF451A03),
      trayInner: Color(0xFF271005),
      tileTop: Color(0xFFFFFBEB),
      tileBottom: Color(0xFFFDE68A),
      tileBorder: Color(0xFFB45309),
      textColor: Color(0xFF991B1B),
      solvedGlow: Color(0xFF22C55E),
    ),
  ];

  static const List<StudioBackgroundOption> backgrounds = [
    StudioBackgroundOption(
      id: 'warm_walnut',
      name: 'Warm Tabletop',
      subtitle: 'Woodcraft Studio',
      assetPath: 'assets/images/backgrounds/bg_1.png',
      accentColor: Color(0xFFF59E0B),
    ),
    StudioBackgroundOption(
      id: 'midnight_slate',
      name: 'Midnight Slate',
      subtitle: 'Esports Arena',
      assetPath: 'assets/images/backgrounds/bg_2.png',
      accentColor: Color(0xFF38BDF8),
    ),
    StudioBackgroundOption(
      id: 'emerald_felt',
      name: 'Emerald Felt',
      subtitle: 'Tournament Table',
      assetPath: 'assets/images/backgrounds/bg_3.png',
      accentColor: Color(0xFF34D399),
    ),
    StudioBackgroundOption(
      id: 'ruby_velvet',
      name: 'Ruby Velvet',
      subtitle: 'Grand Salon',
      assetPath: 'assets/images/backgrounds/bg_4.png',
      accentColor: Color(0xFFFB7185),
    ),
  ];

  static const List<BoardModeOption> boardModes = [
    BoardModeOption(gridSize: 3, label: '3×3', subtitle: '8 Tiles'),
    BoardModeOption(gridSize: 4, label: '4×4', subtitle: '15 Tiles'),
    BoardModeOption(gridSize: 5, label: '5×5', subtitle: '24 Tiles'),
    BoardModeOption(gridSize: 6, label: '6×6', subtitle: '35 Tiles'),
  ];
}

