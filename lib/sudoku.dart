/// An API for generating and solving Sudoku puzzles.
///
library sudoku;

import 'package:sudoku/src/generator.dart';
import 'package:sudoku/src/grid.dart';

/// Provide access to the Sudoku API.
class Sudoku {
  late final generator;
  String? currentPuzzle;
  Grid? grid;
  late bool singleStep;

  Sudoku([this.singleStep = false]) {
    generator = SudokuGenerator();
  }

  factory Sudoku.sudoku(String puzzle, [singleStep = false]) {
    var sudoku = Sudoku(singleStep);
    sudoku.setSudoku(puzzle);
    return sudoku;
  }

  /// **getSolutions** for specified puzzle.
  ///
  Set<String> getSolutions(String? puzzle) {
    if (puzzle != null) {
      setSudoku(puzzle);
    }
    if (currentPuzzle == null) {
      throw Exception();
    }

    // Solve
    return {grid.toString()};
  }

  /// **getSudoku** gets a puzzle, and makes it current.
  ///
  String getSudoku() {
    var puzzle = generator.newSudokuPuzzle();
    setSudoku(puzzle);
    return puzzle;
  }

  void setSudoku(String puzzle) {
    var puzzleList = puzzle.split('\n');
    grid = Grid.sudokuPuzzle(puzzleList, singleStep);
    currentPuzzle = puzzle;
  }

  void invokeAllStrategies([bool explain = false, bool showPossible = false]) {
    if (grid == null) {
      throw Exception();
    }
    return grid!.invokeAllStrategies(explain, showPossible);
  }

  bool explainStrategy(Solve strategy) {
    if (grid == null) {
      throw Exception();
    }
    var updated = strategy(grid!);
    if (updated) {
      print(grid!.messageString);
    }
    return updated;
  }

  String getExplanation() {
    if (grid == null) {
      throw Exception();
    }
    return grid!.messageString;
  }
}
