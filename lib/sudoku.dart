/// An API for generating and solving Sudoku puzzles.
///
library sudoku;

import 'package:sudoku/src/generator.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/strategy/hiddenSingleStrategy.dart';
import 'package:sudoku/src/strategy/updatePossibleStrategy.dart';

/// Provide access to the Sudoku API.
class Sudoku {
  late final generator;
  String? currentPuzzle;
  Grid? grid;
  late bool singleStep;

  Sudoku([this.singleStep = false]) {
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
    grid = Grid.sudokuPuzzle(puzzleList, singleStep);
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

  bool updatePossible() => invokeStrategy(updatePossibleStrategy);
  bool checkUnique() => invokeStrategy(hiddenSingleStrategy);

  bool explainStrategy(Strategy strategy) {
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
