import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// Provide access to the Sudoku API.
abstract class Puzzle {
  Puzzle.puzzle(puzzleList, singleStep);
  String invokeAllStrategies({
    bool explain = false,
    bool showPossible = false,
    List<Strategy>? easyStrategies,
    List<Strategy>? toughStrategies,
  });
  String get messageString;
  String toString();
  Grid get grid;
}

abstract class PuzzleDecorator implements Puzzle {
  late final Puzzle puzzle;
}
