import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// Abstract class for Puzzles, subclass is Sudoku
abstract class Puzzle {
  Puzzle.puzzle(puzzleList, singleStep, {clearStateCallback: null});
  String solve({
    bool explain = false,
    bool showPossible = false,
    List<Strategy>? easyStrategies,
    List<Strategy>? toughStrategies,
    Function? toStr,
  });
  void clearState();
  void Function()? clearStateCallback = null;
  String get messageString;
  String toString();
  Sudoku get sudoku;
  Map<String, Region> get allRegions;
}

/// Puzzle Decorator for additional puzzle types
abstract class PuzzleDecorator implements Puzzle {
  late final Puzzle puzzle;

  void clearState() {
    if (clearStateCallback != null) clearStateCallback!();
  }
}
