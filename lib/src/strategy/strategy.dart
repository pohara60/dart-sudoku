import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';

abstract class Strategy {
  final Puzzle puzzle;
  late final Sudoku sudoku;
  final String explanation;
  Strategy(this.puzzle, this.explanation) {
    this.sudoku = puzzle.sudoku;
  }

  bool solve();
}
