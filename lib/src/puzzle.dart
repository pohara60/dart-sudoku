import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

import 'region.dart';

/// Provide access to the Sudoku API.
///
abstract class Puzzle {
  Puzzle.puzzle(puzzleList, singleStep);
  String solve({
    bool explain = false,
    bool showPossible = false,
    List<Strategy>? easyStrategies,
    List<Strategy>? toughStrategies,
  });
  String get messageString;
  String toString();
  Sudoku get sudoku;
  Map<String, Region> get regions;
}

abstract class PuzzleDecorator implements Puzzle {
  late final Puzzle puzzle;
}
