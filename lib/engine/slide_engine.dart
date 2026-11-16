import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/customization.dart';
import '../services/storage_service.dart';

class SlideEngine extends ChangeNotifier {
  int gridSize = 5;
  List<int> board = []; // 0 represents empty slot
  List<List<int>> history = [];
  int moves = 0;
  int elapsedSeconds = 0;
  int? hintedTileIndex;
  bool isSolved = false;
  bool isPhotoPreset = false;

  static const List<int> photoPreset5x5 = [
    1, 2, 3, 4, 5,
    6, 7, 8, 9, 10,
    11, 12, 13, 14, 15,
    16, 22, 0, 17, 24,
    21, 18, 19, 23, 20,
  ];

  SlideEngine() {
    final mode = SlideCustomization.boardModes[StorageService.gridSizeIndex];
    startNewGame(mode.gridSize);
  }

  int get totalTiles => gridSize * gridSize - 1;
  int get emptyIndex => board.indexOf(0);

  int get correctCount {
    int count = 0;
    for (int i = 0; i < board.length - 1; i++) {
      if (board[i] == i + 1) count++;
    }
    return count;
  }

  void startNewGame(int newSize) {
    gridSize = newSize.clamp(3, 6);
    board = List<int>.generate(gridSize * gridSize, (i) => i == gridSize * gridSize - 1 ? 0 : i + 1);
    _shuffleSolvable();
    history.clear();
    moves = 0;
    elapsedSeconds = 0;
    hintedTileIndex = null;
    isSolved = false;
    isPhotoPreset = false;
    notifyListeners();
  }

  /// Loads the exact 5x5 board state from the uploaded wooden puzzle photo!
  void loadPhotoChallenge() {
    gridSize = 5;
    StorageService.gridSizeIndex = 2;
    StorageService.save();
    board = List<int>.from(photoPreset5x5);
    history.clear();
    moves = 0;
    elapsedSeconds = 0;
    hintedTileIndex = null;
    isSolved = false;
    isPhotoPreset = true;
    notifyListeners();
  }

  void _shuffleSolvable() {
    final rng = math.Random();
    int prevEmpty = -1;
    final steps = gridSize * gridSize * 12;
    for (int s = 0; s < steps; s++) {
      final empty = board.indexOf(0);
      final er = empty ~/ gridSize;
      final ec = empty % gridSize;
      final neighbors = <int>[];
      if (er > 0) neighbors.add((er - 1) * gridSize + ec);
      if (er < gridSize - 1) neighbors.add((er + 1) * gridSize + ec);
      if (ec > 0) neighbors.add(er * gridSize + (ec - 1));
      if (ec < gridSize - 1) neighbors.add(er * gridSize + (ec + 1));
      neighbors.remove(prevEmpty);
      final pick = neighbors[rng.nextInt(neighbors.length)];
      prevEmpty = empty;
      board[empty] = board[pick];
      board[pick] = 0;
    }
    if (_checkSolved()) {
      // Ensure never trivially solved after shuffle
      final empty = board.indexOf(0);
      final swapIdx = empty > 0 ? empty - 1 : 1;
      board[empty] = board[swapIdx];
      board[swapIdx] = 0;
    }
  }

  void tickSecond() {
    if (!isSolved && moves > 0) {
      elapsedSeconds += 1;
      notifyListeners();
    }
  }

  bool canSlideIndex(int tileIndex) {
    if (tileIndex < 0 || tileIndex >= board.length) return false;
    final empty = emptyIndex;
    if (tileIndex == empty) return false;
    final tr = tileIndex ~/ gridSize;
    final tc = tileIndex % gridSize;
    final er = empty ~/ gridSize;
    final ec = empty % gridSize;
    return tr == er || tc == ec;
  }

  /// Slides one or an entire line of tiles in the same row/col into the empty slot!
  bool tapTile(int tileIndex) {
    if (isSolved || !canSlideIndex(tileIndex)) return false;
    history.add(List<int>.from(board));
    if (history.length > 100) history.removeAt(0);

    final empty = emptyIndex;
    final tr = tileIndex ~/ gridSize;
    final tc = tileIndex % gridSize;
    final er = empty ~/ gridSize;
    final ec = empty % gridSize;

    int stepCount = 0;
    if (tr == er) {
      final dir = tc < ec ? -1 : 1;
      for (int c = ec; c != tc; c += dir) {
        final cur = er * gridSize + c;
        final next = er * gridSize + (c + dir);
        board[cur] = board[next];
        stepCount++;
      }
      board[tileIndex] = 0;
    } else if (tc == ec) {
      final dir = tr < er ? -1 : 1;
      for (int r = er; r != tr; r += dir) {
        final cur = r * gridSize + ec;
        final next = (r + dir) * gridSize + ec;
        board[cur] = board[next];
        stepCount++;
      }
      board[tileIndex] = 0;
    }

    moves += stepCount;
    hintedTileIndex = null;
    HapticFeedback.lightImpact();

    if (_checkSolved()) {
      isSolved = true;
      HapticFeedback.heavyImpact();
      StorageService.gamesWon += 1;
      final prevMoves = StorageService.bestMovesBySize[gridSize];
      if (prevMoves == null || moves < prevMoves) {
        StorageService.bestMovesBySize[gridSize] = moves;
      }
      final prevSec = StorageService.bestSecondsBySize[gridSize];
      if (prevSec == null || elapsedSeconds < prevSec) {
        StorageService.bestSecondsBySize[gridSize] = elapsedSeconds;
      }
      StorageService.save();
    }

    notifyListeners();
    return true;
  }

  void slideDirection(int dr, int dc) {
    // Move tile opposite to swipe direction into the empty space
    final empty = emptyIndex;
    final er = empty ~/ gridSize;
    final ec = empty % gridSize;
    final targetR = er - dr;
    final targetC = ec - dc;
    if (targetR >= 0 && targetR < gridSize && targetC >= 0 && targetC < gridSize) {
      tapTile(targetR * gridSize + targetC);
    }
  }

  void undo() {
    if (history.isEmpty || isSolved) return;
    board = history.removeLast();
    moves = math.max(0, moves - 1);
    hintedTileIndex = null;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void showHint() {
    if (isSolved) return;
    final empty = emptyIndex;
    final er = empty ~/ gridSize;
    final ec = empty % gridSize;
    final candidates = <int>[];
    if (er > 0) candidates.add((er - 1) * gridSize + ec);
    if (er < gridSize - 1) candidates.add((er + 1) * gridSize + ec);
    if (ec > 0) candidates.add(er * gridSize + (ec - 1));
    if (ec < gridSize - 1) candidates.add(er * gridSize + (ec + 1));

    int bestIdx = candidates.first;
    int bestScore = 1 << 30;
    for (final idx in candidates) {
      final copy = List<int>.from(board);
      copy[empty] = copy[idx];
      copy[idx] = 0;
      // Avoid exact undo state if alternatives exist
      if (history.isNotEmpty && listEquals(copy, history.last) && candidates.length > 1) {
        continue;
      }
      final score = _manhattan(copy);
      if (score < bestScore) {
        bestScore = score;
        bestIdx = idx;
      }
    }
    hintedTileIndex = bestIdx;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  int _manhattan(List<int> state) {
    int dist = 0;
    for (int i = 0; i < state.length; i++) {
      final v = state[i];
      if (v == 0) continue;
      final target = v - 1;
      final r1 = i ~/ gridSize;
      final c1 = i % gridSize;
      final r2 = target ~/ gridSize;
      final c2 = target % gridSize;
      dist += (r1 - r2).abs() + (c1 - c2).abs();
    }
    return dist;
  }

  bool _checkSolved() {
    for (int i = 0; i < board.length - 1; i++) {
      if (board[i] != i + 1) return false;
    }
    return board.last == 0;
  }
}

