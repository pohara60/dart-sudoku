import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/puzzle.dart';

abstract class Strategy {
  final Puzzle puzzle;
  late final Grid grid;
  final String explanation;
  Strategy(this.puzzle, this.explanation) {
    this.grid = puzzle.grid;
  }

  bool solve();
}
