/// An API for generating and solving Sudoku puzzles.
///
library sudoku;

import 'package:sudoku/src/arrow.dart';
import 'package:sudoku/src/domino.dart';
import 'package:sudoku/src/generator.dart';
import 'package:sudoku/src/sandwich.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/sudokuX.dart';
import 'package:sudoku/src/thermo.dart';
import 'package:sudoku/src/whisper.dart';

/// Provide access to the Sudoku API.
class SudokuAPI {
  late final generator;
  String? currentPuzzle;
  Puzzle? puzzle;
  late bool singleStep;

  SudokuAPI([this.singleStep = false]) {
    generator = SudokuGenerator();
  }

  factory SudokuAPI.sudoku(String puzzleString, [singleStep = false]) {
    var sudoku = SudokuAPI(singleStep);
    sudoku.setSudoku(puzzleString);
    return sudoku;
  }

  factory SudokuAPI.killer(String sudokuString, List<List<dynamic>> killerGrid,
      [bool partial = false, bool singleStep = false]) {
    var sudoku = SudokuAPI(singleStep);
    sudoku.setSudoku(sudokuString);
    var message = sudoku.addKiller(killerGrid, partial);
    if (message != '') print(message);

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

  String setSudoku(String puzzleString) {
    var puzzleList = puzzleString.split('\n');
    puzzle = Sudoku.puzzle(puzzleList, singleStep);
    currentPuzzle = puzzleString;
    return '';
  }

  String addKiller(List<List<dynamic>> killerGrid, [bool partial = false]) {
    if (puzzle == null) {
      return 'No puzzle!';
    }
    currentPuzzle = currentPuzzle! + killerGrid.join('\n');
    puzzle = Killer.puzzle(puzzle!, killerGrid, partial);
    return puzzle?.messageString ?? '';
  }

  String addWhisper(List<List<String>> whisperLines) {
    if (puzzle == null) {
      return 'No puzzle!';
    }
    currentPuzzle = currentPuzzle! + whisperLines.join('\n');
    puzzle = Whisper.puzzle(puzzle!, whisperLines);
    return puzzle?.messageString ?? '';
  }

  String addArrow(List<List<String>> arrowLines) {
    if (puzzle == null) {
      return 'No puzzle!';
    }
    currentPuzzle = currentPuzzle! + arrowLines.join('\n');
    puzzle = Arrow.puzzle(puzzle!, arrowLines);
    return puzzle?.messageString ?? '';
  }

  String addThermo(List<List<String>> thermoLines) {
    if (puzzle == null) {
      return 'No puzzle!';
    }
    currentPuzzle = currentPuzzle! + thermoLines.join('\n');
    puzzle = Thermo.puzzle(puzzle!, thermoLines);
    return puzzle?.messageString ?? '';
  }

  String addDomino(List<List<String>> dominoLines, [bool negative = false]) {
    if (puzzle == null) {
      return 'No puzzle!';
    }
    currentPuzzle = currentPuzzle! + dominoLines.join('\n');
    puzzle = Domino.puzzle(puzzle!, dominoLines, negative);
    return puzzle?.messageString ?? '';
  }

  String addSandwich(List<List<dynamic>> sandwichLines) {
    if (puzzle == null) {
      return 'No puzzle!';
    }
    currentPuzzle = currentPuzzle! + sandwichLines.join('\n');
    puzzle = Sandwich.puzzle(puzzle!, sandwichLines);
    return puzzle?.messageString ?? '';
  }

  String addSudokuX() {
    if (puzzle == null) {
      return 'No puzzle!';
    }
    currentPuzzle = currentPuzzle! + 'SudokuX\n';
    puzzle = SudokuX.puzzle(puzzle!);
    return puzzle?.messageString ?? '';
  }

  String solve([bool explain = false, bool showPossible = false]) {
    if (puzzle == null) {
      throw Exception();
    }
    return puzzle!.solve(explain: explain, showPossible: showPossible);
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
