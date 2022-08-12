/// An API for generating and solving Sudoku puzzles.
///
library sudoku;

import 'package:sudoku/src/generator.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/puzzle.dart';

/// Provide access to the Sudoku API.
class Sudoku {
  late final generator;
  String? currentPuzzle;
  Puzzle? puzzle;
  late bool singleStep;

  Sudoku([this.singleStep = false]) {
    generator = SudokuGenerator();
  }

  factory Sudoku.sudoku(String puzzleString, [singleStep = false]) {
    var sudoku = Sudoku(singleStep);
    sudoku.setSudoku(puzzleString);
    return sudoku;
  }

  factory Sudoku.killer(String sudokuString, List<List<dynamic>> killerGrid,
      [singleStep = false]) {
    var sudoku = Sudoku(singleStep);
    sudoku.setSudoku(sudokuString);
    sudoku.addKiller(killerGrid);

    return sudoku;
  }

  /// **getSolutions** for specified puzzle.
  ///
  Set<String> getSolutions(String? puzzleString) {
    if (puzzleString != null) {
      setSudoku(puzzleString);
    }
    if (currentPuzzle == null) {
      throw Exception();
    }

    // Solve
    return {puzzle.toString()};
  }

  /// **getSudoku** gets a puzzle, and makes it current.
  ///
  String getSudoku() {
    var puzzle = generator.newSudokuPuzzle();
    setSudoku(puzzle);
    return puzzle;
  }

  void setSudoku(String puzzleString) {
    var puzzleList = puzzleString.split('\n');
    puzzle = Grid.puzzle(puzzleList, singleStep);
    currentPuzzle = puzzleString;
  }

  void addKiller(List<List<dynamic>> killerGrid) {
    if (puzzle == null) {
      throw Exception();
    }
    puzzle = Killer.puzzle(puzzle!, killerGrid);
    currentPuzzle = currentPuzzle! + killerGrid.join('\n');
  }

  String invokeAllStrategies(
      [bool explain = false, bool showPossible = false]) {
    if (puzzle == null) {
      throw Exception();
    }
    return puzzle!
        .invokeAllStrategies(explain: explain, showPossible: showPossible);
  }

  bool explainStrategy(Solve strategy) {
    if (puzzle == null) {
      throw Exception();
    }
    var updated = strategy(puzzle!);
    if (updated) {
      print(puzzle!.messageString);
    }
    return updated;
  }

  String getExplanation() {
    if (puzzle == null) {
      throw Exception();
    }
    return puzzle!.messageString;
  }
}
