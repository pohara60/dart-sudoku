/// An API for generating and solving Sudoku puzzles.
///
library sudoku;

import 'package:sudoku/generator.dart';
import 'package:sudoku/grid.dart';

/// Provide access to the Sudoku API.
class Sudoku {
  late final generator;
  String? currentPuzzle;
  Grid? grid;

  Sudoku() {
    generator = SudokuGenerator();
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
    grid = Grid.sudokuPuzzle(puzzleList);
    currentPuzzle = puzzle;
  }

  void invokeAllStrategies(bool explain) {
    if (grid == null) {
      throw Exception();
    }
    return grid!.invokeAllStrategies(explain);
  }

  bool invokeStrategy(Strategy strategy) {
    if (grid == null) {
      throw Exception();
    }
    return grid!.invokeStrategy(strategy);
  }

  bool updatePossible() => invokeStrategy(grid!.updatePossible);
  bool checkUnique() => invokeStrategy(grid!.hiddenSingleStrategy);

  bool explainStrategy(Strategy strategy) {
    if (grid == null) {
      throw Exception();
    }
    var updated = strategy();
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
