import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';

/// Provide access to the Sudoku API.
abstract class Puzzle {
  Puzzle.puzzle(puzzleList, singleStep);
  String invokeAllStrategies([bool explain = false, bool showPossible = false]);
  String get messageString;
  String toString();
  Grid get grid;
}

abstract class PuzzleDecorator implements Puzzle {
  late final Puzzle puzzle;
}
