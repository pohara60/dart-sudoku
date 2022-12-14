import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:sudoku/sudokuAPI.dart';

const PROGRAM = 'sudoku';

void main(List<String> arguments) async {
  exitCode = 0; // presume success

  var runner = CommandRunner(PROGRAM, 'Sudoku helper.')
    ..addCommand(SolutionCommand())
    ..addCommand(GetSudokuCommand());
  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    // Arguments exception
    print('$PROGRAM: ${e.message}');
    print('');
    print('${runner.usage}');
  } catch (e) {
    print('$PROGRAM: $e');
  }
}

class SolutionCommand extends Command {
  @override
  final name = 'solution';
  @override
  final description = '''Get solutions.
  
The [argument] is the puzzle.

For example:
  sudoku solution puzzle''';

  SolutionCommand() {}

  @override
  void run() {
    // Validate options
    var puzzles = argResults!.rest;
    if (puzzles.length > 0) {
      // Get and print solutions
      final puzzle = puzzles[0];
      var sudoku = SudokuAPI.sudoku(puzzle);
      var result = sudoku.solve(true, false);
      print(result);
      // final solutions = sudoku.getSolutions(puzzle);
      // for (var solution in solutions) {
      //   print('Solution for $puzzle is $solution');
      // }
    }
  }
}

class GetSudokuCommand extends Command {
  @override
  final name = 'getSudoku';
  @override
  final description = 'GetSudoku puzzle.';

  // ignore: empty_constructor_bodies
  GetSudokuCommand();

  @override
  void run() {
    // Get and print puzzle
    final sudoku = SudokuAPI();
    var puzzle = sudoku.getSudoku();
    print('getSudoku = $puzzle');
  }
}
