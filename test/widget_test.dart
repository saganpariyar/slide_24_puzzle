import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slide_24_puzzle/engine/slide_engine.dart';
import 'package:slide_24_puzzle/main.dart';
import 'package:slide_24_puzzle/models/customization.dart';

void main() {
  test('Slide 24 customization provides 4 options per selection', () {
    expect(SlideCustomization.profiles.length, 4);
    expect(SlideCustomization.trayThemes.length, 4);
    expect(SlideCustomization.backgrounds.length, 4);
    expect(SlideCustomization.boardModes.length, 4);
  });

  test('SlideEngine defaults to 5x5 (24 tiles), supports multi-tile sliding, undo, and photo preset', () {
    final engine = SlideEngine();
    expect(engine.gridSize, 5);
    expect(engine.totalTiles, 24);
    expect(engine.isSolved, isFalse);

    // Load exact photo challenge state and slide a tile in the same row as 0
    engine.loadPhotoChallenge();
    expect(engine.board.length, 25);
    final emptyIdx = engine.emptyIndex; // index 17 (row 3, col 2)
    expect(emptyIdx, 17);

    // Tap tile at index 15 (row 3, col 0) -> slides 2 tiles in row 3!
    final slid = engine.tapTile(15);
    expect(slid, isTrue);
    expect(engine.moves, 2);
    expect(engine.emptyIndex, 15);

    engine.undo();
    expect(engine.emptyIndex, 17);
  });

  testWidgets('Slide 24 GameScreen renders tray, modes, and actions', (tester) async {
    await tester.pumpWidget(const Slide24PuzzleApp());
    await tester.pumpAndSettle();

    expect(find.text('SLIDE 24 PUZZLE'), findsOneWidget);
    expect(find.text('Photo 5×5'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(4));
  });
}
