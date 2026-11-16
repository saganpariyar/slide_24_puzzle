import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../engine/slide_engine.dart';
import '../models/customization.dart';
import '../services/storage_service.dart';
import '../widgets/customization_sheet.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final SlideEngine _engine;
  Timer? _timer;
  final FocusNode _focusNode = FocusNode();
  Offset? _panDelta;

  @override
  void initState() {
    super.initState();
    _engine = SlideEngine();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _engine.tickSecond());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode.dispose();
    _engine.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp || event.logicalKey == LogicalKeyboardKey.keyW) {
      _engine.slideDirection(-1, 0);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown || event.logicalKey == LogicalKeyboardKey.keyS) {
      _engine.slideDirection(1, 0);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft || event.logicalKey == LogicalKeyboardKey.keyA) {
      _engine.slideDirection(0, -1);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.keyD) {
      _engine.slideDirection(0, 1);
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyZ) {
      _engine.undo();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyH) {
      _engine.showHint();
      return KeyEventResult.handled;
    } else if (event.logicalKey == LogicalKeyboardKey.keyR) {
      _engine.startNewGame(_engine.gridSize);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _openCustomization() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomizationSheet(
        onChanged: () => setState(() {}),
        onGridSizeChanged: (size) => _engine.startNewGame(size),
      ),
    );
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _engine,
          builder: (context, _) {
            final profile = SlideCustomization.profiles[StorageService.profileIndex];
            final theme = SlideCustomization.trayThemes[StorageService.trayThemeIndex];
            final bg = SlideCustomization.backgrounds[StorageService.backgroundIndex];
            final bestMoves = StorageService.bestMovesBySize[_engine.gridSize];

            return Stack(
              fit: StackFit.expand,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(bg.assetPath, key: ValueKey(bg.assetPath), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                ),
                Container(color: const Color(0x55020617)),
                SafeArea(
                  child: Column(
                    children: [
                      // Header Bar with App Icon + Profile Avatar + Customize
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                        child: Row(
                          children: [
                            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/icon/app_icon.png', width: 44, height: 44)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('SLIDE ${_engine.totalTiles} PUZZLE', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 0.9, color: Colors.white)),
                                  Text('${_engine.gridSize}×${_engine.gridSize} • ${theme.name}', style: TextStyle(fontSize: 11, color: bg.accentColor, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _openCustomization,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xCC0F172A),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: profile.accentColor, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    ClipOval(child: Image.asset(profile.assetPath, width: 26, height: 26, fit: BoxFit.cover)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.tune_rounded, color: Colors.white, size: 17),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stats Bar (Moves, Correct Tiles, Time, Best)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        child: Row(
                          children: [
                            _statCard('MOVES', '${_engine.moves}', bg.accentColor),
                            const SizedBox(width: 8),
                            _statCard('IN PLACE', '${_engine.correctCount}/${_engine.totalTiles}', const Color(0xFF34D399)),
                            const SizedBox(width: 8),
                            _statCard('TIME', _formatTime(_engine.elapsedSeconds), Colors.white),
                            const SizedBox(width: 8),
                            _statCard('BEST', bestMoves != null ? '$bestMoves' : '--', const Color(0xFFFBBF24)),
                          ],
                        ),
                      ),

                      // Quick 4-Mode Selector (3x3, 4x4, 5x5, 6x6) + Photo Challenge
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          children: [
                            ...List.generate(SlideCustomization.boardModes.length, (idx) {
                              final m = SlideCustomization.boardModes[idx];
                              final active = _engine.gridSize == m.gridSize && !_engine.isPhotoPreset;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(m.label),
                                  selected: active,
                                  selectedColor: bg.accentColor.withValues(alpha: 0.25),
                                  backgroundColor: const Color(0xCC0F172A),
                                  side: BorderSide(color: active ? bg.accentColor : const Color(0xFF334155)),
                                  labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : const Color(0xFF94A3B8)),
                                  onSelected: (_) {
                                    StorageService.gridSizeIndex = idx;
                                    StorageService.save();
                                    _engine.startNewGame(m.gridSize);
                                  },
                                ),
                              );
                            }),
                            ActionChip(
                              avatar: const Icon(Icons.photo_camera_rounded, size: 15, color: Color(0xFFFBBF24)),
                              label: const Text('Photo 5×5'),
                              backgroundColor: _engine.isPhotoPreset ? const Color(0xFFFBBF24).withValues(alpha: 0.25) : const Color(0xCC0F172A),
                              side: BorderSide(color: _engine.isPhotoPreset ? const Color(0xFFFBBF24) : const Color(0xFF334155)),
                              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                              onPressed: _engine.loadPhotoChallenge,
                            ),
                          ],
                        ),
                      ),

                      // Centered Tactile Sliding Board
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final side = math.min(constraints.maxWidth, constraints.maxHeight).clamp(240.0, 480.0);
                                return GestureDetector(
                                  onPanStart: (_) => _panDelta = Offset.zero,
                                  onPanUpdate: (d) => _panDelta = (_panDelta ?? Offset.zero) + d.delta,
                                  onPanEnd: (_) {
                                    final delta = _panDelta;
                                    _panDelta = null;
                                    if (delta == null || delta.distance < 22) return;
                                    if (delta.dx.abs() > delta.dy.abs()) {
                                      _engine.slideDirection(0, delta.dx > 0 ? 1 : -1);
                                    } else {
                                      _engine.slideDirection(delta.dy > 0 ? 1 : -1, 0);
                                    }
                                  },
                                  child: _buildPuzzleTray(side, theme),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Action Bar (Undo, Hint, Shuffle, Customize)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: _actionBtn(
                                icon: Icons.undo_rounded,
                                label: 'Undo',
                                color: const Color(0xFF94A3B8),
                                onTap: _engine.history.isEmpty ? null : _engine.undo,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _actionBtn(
                                icon: Icons.lightbulb_rounded,
                                label: 'Hint',
                                color: const Color(0xFFFBBF24),
                                onTap: _engine.showHint,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _actionBtn(
                                icon: Icons.shuffle_rounded,
                                label: 'Shuffle',
                                color: bg.accentColor,
                                onTap: () => _engine.startNewGame(_engine.gridSize),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _actionBtn(
                                icon: Icons.palette_rounded,
                                label: 'Themes',
                                color: const Color(0xFFE879F9),
                                onTap: _openCustomization,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (_engine.isSolved) _buildSolvedOverlay(theme),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _statCard(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xCC0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 9, letterSpacing: 1.0, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8))),
            const SizedBox(height: 2),
            Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn({required IconData icon, required String label, required Color color, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: enabled ? color.withValues(alpha: 0.16) : const Color(0x660F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: enabled ? color : const Color(0xFF1E293B), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: enabled ? color : const Color(0xFF475569)),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: enabled ? Colors.white : const Color(0xFF475569))),
          ],
        ),
      ),
    );
  }

  Widget _buildPuzzleTray(double side, TrayThemeOption theme) {
    final n = _engine.gridSize;
    final outerPad = side * 0.055;
    final innerSide = side - outerPad * 2;
    final gap = math.max(3.0, innerSide * 0.014);
    final cell = (innerSide - gap * (n + 1)) / n;

    // Build positioned widgets for tiles 1..totalTiles so AnimatedPositioned slides smoothly
    final tiles = <Widget>[];
    for (int idx = 0; idx < _engine.board.length; idx++) {
      final val = _engine.board[idx];
      if (val == 0) continue;
      final row = idx ~/ n;
      final col = idx % n;
      final left = gap + col * (cell + gap);
      final top = gap + row * (cell + gap);
      final isCorrect = val == idx + 1;
      final isHinted = _engine.hintedTileIndex == idx;
      final canMove = _engine.canSlideIndex(idx);

      tiles.add(
        AnimatedPositioned(
          key: ValueKey(val),
          duration: const Duration(milliseconds: 145),
          curve: Curves.easeOutCubic,
          left: left,
          top: top,
          width: cell,
          height: cell,
          child: GestureDetector(
            onTap: canMove ? () => _engine.tapTile(idx) : null,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.tileTop, theme.tileBottom],
                ),
                borderRadius: BorderRadius.circular(math.max(6, cell * 0.14)),
                border: Border.all(
                  color: isHinted
                      ? const Color(0xFFFBBF24)
                      : (canMove ? theme.tileBorder : theme.tileBorder.withValues(alpha: 0.7)),
                  width: isHinted ? 2.6 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.32),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Carved inner groove border matching wooden tiles in the photo
                  Positioned.fill(
                    child: Container(
                      margin: EdgeInsets.all(math.max(3, cell * 0.075)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(math.max(4, cell * 0.09)),
                        border: Border.all(color: theme.tileBorder.withValues(alpha: 0.45), width: 1.2),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '$val',
                      style: TextStyle(
                        fontSize: (cell * 0.42).clamp(13.0, 34.0),
                        fontWeight: FontWeight.w900,
                        color: theme.textColor,
                      ),
                    ),
                  ),
                  if (isCorrect)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: theme.solvedGlow, shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: side,
      height: side,
      padding: EdgeInsets.all(outerPad),
      decoration: BoxDecoration(
        color: theme.trayOuter,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.tileBorder.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.trayInner,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.35), width: 2),
        ),
        child: Stack(children: tiles),
      ),
    );
  }

  Widget _buildSolvedOverlay(TrayThemeOption theme) {
    return Container(
      color: const Color(0xBB020617),
      child: Center(
        child: Container(
          width: 310,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF34D399), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 52),
              const SizedBox(height: 8),
              Text('${_engine.gridSize}×${_engine.gridSize} SOLVED!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 6),
              Text(
                '${_engine.moves} Moves • ${_formatTime(_engine.elapsedSeconds)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF34D399)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF34D399), foregroundColor: Colors.black),
                  onPressed: () => _engine.startNewGame(_engine.gridSize),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Play Again', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
