import 'dart:convert';
import 'dart:io';

import 'package:sudoku/sudokuAPI.dart';
import 'package:test/test.dart';

void main() {
  var puzzle1 = [
    "72.4.8.3.",
    ".8.....47",
    "4.1.768.2",
    "81.739...",
    "...851...",
    "...264.8.",
    "2.968.413",
    "34......8",
    "168943275"
  ].join(
    '\n',
  );
  var solution1 = [
    '72.4.8.3.',
    '.8.....47',
    '4.1.768.2',
    '81.739...',
    '...851...',
    '...264.8.',
    '2.968.413',
    '34......8',
    '168943275',
    'Hidden Group, set R4C3 = 24',
    'Hidden Group, set R5C3 = 24',
    'Hidden Group, set R5C7 = 37',
    'Hidden Group, set R6C7 = 37',
    'Hidden Single, R5C1 = 6',
    'Hidden Single, R6C9 = 1',
    'Naked Group, remove group 249 from R5C2 = 37',
    'Y-Wing, R hinge R1C3 B3, remove value 9 from R2C7 = 156',
    'Y-Wing, R hinge R1C9 B3, remove value 5 from R1C7 = 169',
    'Y-Wing, R hinge R1C9 B1, remove value 5 from R3C2 = 39',
    'Hidden Single, R1C3 = 5',
    'Hidden Single, R2C3 = 6',
    'Hidden Single, R2C4 = 3',
    'Hidden Single, R3C2 = 3',
    'Hidden Single, R3C8 = 9',
    'Hidden Single, R4C8 = 5',
    'Hidden Single, R5C8 = 2',
    'Hidden Single, R5C9 = 9',
    'Hidden Single, R6C2 = 9',
    'Hidden Single, R6C3 = 3',
    'Hidden Single, R6C7 = 7',
    'Hidden Single, R7C2 = 5',
    'Hidden Single, R7C6 = 7',
    'Hidden Single, R8C3 = 7',
    'Hidden Single, R8C4 = 1',
    'Hidden Single, R8C6 = 5',
    'Hidden Single, R8C8 = 6',
    'Hidden Single, R1C5 = 9',
    'Hidden Single, R1C7 = 1',
    'Naked Single, R1C9 = 6',
    'Naked Single, R2C1 = 9',
    'Hidden Single, R2C5 = 1',
    'Naked Single, R2C6 = 2',
    'Hidden Single, R2C7 = 5',
    'Naked Single, R3C4 = 5',
    'Hidden Single, R4C3 = 2',
    'Naked Single, R4C7 = 6',
    'Hidden Single, R4C9 = 4',
    'Naked Single, R5C2 = 7',
    'Naked Single, R5C3 = 4',
    'Naked Single, R5C7 = 3',
    'Naked Single, R6C1 = 5',
    'Naked Single, R8C5 = 2',
    'Naked Single, R8C7 = 9',
    'Solved!',
    'Solution iterations=9',
    '725498136',
    '986312547',
    '431576892',
    '812739654',
    '674851329',
    '593264781',
    '259687413',
    '347125968',
    '168943275',
  ];

  var puzzle2 =
      // XYZ Wing, not solved - needs Simple Colouring
      [
    "6.......8",
    "5..9.8..7",
    "82...1.3.",
    "34.2.9.8.",
    "2...8.3..",
    "18.3.7.25",
    "75.4...92",
    "9....5..4",
    "4...9...3"
  ].join(
    '\n',
  );
  var solution2 = [
    '6.......8',
    '5..9.8..7',
    '82...1.3.',
    '34.2.9.8.',
    '2...8.3..',
    '18.3.7.25',
    '75.4...92',
    '9....5..4',
    '4...9...3',
    'Naked Group, remove group 46 from R4C5 = 15',
    'Naked Group, remove group 46 from R5C4 = 15',
    'Naked Group, remove group 136 from R1C2 = 79',
    'Naked Group, remove group 136 from R5C2 = 79',
    'Pointing Group, B4,C3, remove group 56 from R7C3 = 138',
    'Pointing Group, B4,C3, remove group 56 from R8C3 = 1238',
    'Pointing Group, B4,C3, remove group 56 from R9C3 = 128',
    'Line Box Reduction, B6,C9, remove group 1 from R4C7 = 67',
    'Line Box Reduction, B6,C9, remove group 1 from R5C8 = 467',
    'Simple Colouring, Rule 4 R6C7,R1C6, remove value 4 from R1C7 = 1259',
    'Simple Colouring, Rule 4 R6C3,R3C9, remove value 9 from R3C3 = 47',
    'Pointing Group, B1,R1, remove group 9 from R1C7 = 125',
    'XYZ-Wing, R hinge R5C8 B6, remove value 6 from R5C9 = 19',
    'Guess R1C2 = 79, value 7',
    'Hidden Single, R1C3 = 9',
    'Naked Single, R1C4 = 5',
    'Naked Single, R3C3 = 4',
    'Naked Single, R5C2 = 9',
    'Hidden Single, R3C7 = 5',
    'Hidden Single, R3C9 = 9',
    'Hidden Single, R4C5 = 5',
    'Hidden Single, R4C9 = 1',
    'Hidden Single, R5C3 = 5',
    'Naked Single, R5C4 = 1',
    'Hidden Single, R5C8 = 7',
    'Naked Single, R5C9 = 1',
    'Naked Single, R6C3 = 6',
    'Hidden Single, R6C7 = 9',
    'Hidden Single, R9C8 = 5',
    'Hidden Single, R2C7 = 4',
    'Hidden Single, R2C8 = 6',
    'Naked Single, R4C3 = 7',
    'Naked Single, R4C7 = 6',
    'Hidden Single, R5C6 = 6',
    'Naked Single, R6C5 = 4',
    'Hidden Single, R1C6 = 4',
    'Hidden Single, R1C7 = 2',
    'Naked Single, R1C8 = 1',
    'Hidden Single, R2C5 = 2',
    'Hidden Single, R7C5 = 6',
    'Naked Single, R7C6 = 3',
    'Hidden Single, R8C5 = 1',
    'Naked Single, R8C8 = 1',
    'Naked Single, R9C6 = 2',
    'Naked Single, R1C5 = 3',
    'Hidden Single, R3C4 = 6',
    'Naked Single, R3C5 = 7',
    'Hidden Single, R7C3 = 1',
    'Naked Single, R7C7 = 8',
    'Hidden Single, R8C2 = 6',
    'Hidden Single, R8C3 = 2',
    'Hidden Single, R9C2 = 6',
    'Hidden Single, R9C3 = 1',
    'Hidden Single, R2C2 = 1',
    'Naked Single, R2C3 = 3',
    'Hidden Single, R8C4 = 8',
    'Naked Single, R8C7 = 7',
    'Hidden Single, R9C4 = 8',
    'Naked Single, R9C7 = 7',
    'Solved!',
    'Solution iterations=20',
    '679534218',
    '513928467',
    '824671539',
    '347259681',
    '295186371',
    '186347925',
    '751463892',
    '962815714',
    '461892753'
  ];

  var puzzle3 =
      // Simple Colouring
      [
    "..7.836..",
    ".397.68..",
    "826419753",
    "64.19.387",
    ".8.367...",
    ".73.48.6.",
    "39.87..26",
    "7649..138",
    "2.863.97."
  ].join(
    '\n',
  );
  var solution3 = [
    '..7.836..',
    '.397.68..',
    '826419753',
    '64.19.387',
    '.8.367...',
    '.73.48.6.',
    '39.87..26',
    '7649..138',
    '2.863.97.',
    'Naked Group, remove group 25 from R7C6 = 14',
    'Naked Group, remove group 25 from R9C6 = 14',
    'Naked Group, remove group 25 from R6C1 = 19',
    'Naked Group, remove group 25 from R6C9 = 19',
    'Pointing Group, B3,C9, remove group 2 from R5C9 = 1459',
    'Simple Colouring, Rule 4 R7C3,R5C9, remove value 5 from R5C3 = 12',
    'Simple Colouring, Rule 2 R1, remove value 5 from R2C1 = 14',
    'Simple Colouring, Rule 2 R1, set value R2C5 = 5',
    'Simple Colouring, Rule 2 R1, remove value 5 from R8C5 = 2',
    'Simple Colouring, Rule 2 R1, set value R8C6 = 5',
    'Simple Colouring, Rule 2 R1, remove value 5 from R4C6 = 2',
    'Simple Colouring, Rule 2 R1, set value R4C3 = 5',
    'Simple Colouring, Rule 2 R1, remove value 5 from R7C3 = 1',
    'Simple Colouring, Rule 2 R1, set value R7C7 = 5',
    'Simple Colouring, Rule 2 R1, remove value 5 from R9C9 = 4',
    'Simple Colouring, Rule 2 R1, set value R9C2 = 5',
    'Simple Colouring, Rule 2 R1, remove value 5 from R1C2 = 1',
    'Simple Colouring, Rule 2 R1, set value R5C9 = 5',
    'Simple Colouring, Rule 2 R1, remove value 5 from R5C1 = 19',
    'Simple Colouring, Rule 2 R1, set value R6C4 = 5',
    'Simple Colouring, Rule 2 R1, remove value 5 from R6C7 = 2',
    'Simple Colouring, Rule 2 R1, remove value 5 from R1C4 = 2',
    'Simple Colouring, Rule 4 R7C7,R5C1, remove value 5 from R5C7 = 24',
    'Hidden Single, R1C1 = 5',
    'Naked Single, R1C2 = 1',
    'Naked Single, R1C4 = 2',
    'Hidden Single, R2C1 = 4',
    'Hidden Single, R2C9 = 2',
    'Naked Single, R4C6 = 2',
    'Hidden Single, R5C3 = 2',
    'Hidden Single, R5C7 = 4',
    'Naked Single, R6C7 = 2',
    'Naked Single, R7C3 = 1',
    'Hidden Single, R7C6 = 4',
    'Naked Single, R8C5 = 2',
    'Hidden Single, R9C6 = 1',
    'Naked Single, R9C9 = 4',
    'Hidden Single, R1C8 = 4',
    'Naked Single, R1C9 = 9',
    'Naked Single, R2C8 = 1',
    'Hidden Single, R5C8 = 9',
    'Hidden Single, R6C9 = 1',
    'Naked Single, R5C1 = 1',
    'Naked Single, R6C1 = 9',
    'Solved!',
    'Solution iterations=10',
    '517283649',
    '439756812',
    '826419753',
    '645192387',
    '182367495',
    '973548261',
    '391874526',
    '764925138',
    '258631974'
  ];

  var puzzle4 =
      // BUG
      [
    "174832596",
    "593461278",
    "682957..1",
    ".675..9..",
    ".197.36.5",
    "435.968.7",
    "3.16..759",
    "9.8.75.6.",
    "7563.9.82"
  ].join(
    '\n',
  );
  var solution4 = [
    '174832596',
    '593461278',
    '682957..1',
    '.675..9..',
    '.197.36.5',
    '435.968.7',
    '3.16..759',
    '9.8.75.6.',
    '7563.9.82',
    'Swordfish, R3,R5,R9, remove value 4 from R4C5 = 128',
    'Swordfish, R3,R5,R9, remove value 4 from R7C5 = 28',
    'Swordfish, R3,R5,R9, remove value 4 from R8C7 = 13',
    'Swordfish, R3,R5,R9, remove value 4 from R4C8 = 123',
    'XYZ-Wing, C hinge R4C5 B5, remove value 2 from R5C5 = 48',
    'Naked Group, remove group 48 from R4C5 = 12',
    'BUG, R4C8 = 2',
    'Hidden Single, R3C8 = 3',
    'Naked Single, R4C1 = 8',
    'Naked Single, R4C5 = 1',
    'Hidden Single, R4C9 = 3',
    'Hidden Single, R5C1 = 2',
    'Hidden Single, R5C5 = 8',
    'Naked Single, R5C8 = 4',
    'Hidden Single, R6C4 = 2',
    'Naked Single, R6C8 = 1',
    'Hidden Single, R7C5 = 2',
    'Hidden Single, R7C6 = 8',
    'Hidden Single, R8C4 = 1',
    'Hidden Single, R8C9 = 4',
    'Hidden Single, R9C5 = 4',
    'Hidden Single, R9C7 = 1',
    'Naked Single, R3C7 = 4',
    'Naked Single, R4C6 = 4',
    'Naked Single, R7C2 = 4',
    'Naked Single, R8C2 = 2',
    'Naked Single, R8C7 = 3',
    'Solved!',
    'Solution iterations=9',
    '174832596',
    '593461278',
    '682957431',
    '867514923',
    '219783645',
    '435296817',
    '341628759',
    '928175364',
    '756349182'
  ];

  group('API', () {
    test('sudoku1', () {
      var sudoku1 = SudokuAPI.sudoku(puzzle1);
      expect(
        sudoku1.solve(true, false),
        solution1.join(
          '\n',
        ),
      );
    });
    test('sudoku2', () {
      var sudoku2 = SudokuAPI.sudoku(puzzle2);
      expect(
        sudoku2.solve(true, false),
        solution2.join(
          '\n',
        ),
      );
    });
    test('sudoku3', () {
      var sudoku3 = SudokuAPI.sudoku(puzzle3);
      expect(
        sudoku3.solve(true, false),
        solution3.join(
          '\n',
        ),
      );
    });
    test('sudoku4', () {
      var sudoku4 = SudokuAPI.sudoku(puzzle4);
      expect(
        sudoku4.solve(true, false),
        solution4.join(
          '\n',
        ),
      );
    });
  });

  group('Command line', () {
    test_command('solution $puzzle1', solution1);
  });
}

// Test the command line program
// command is the sudoku command, e.g. 'lookup abba'
// output is the list of expected output lines
void test_command(String command, List<String> output) {
  final path = 'bin/sudoku.dart';
  test(command, () async {
    final process =
        await Process.start('dart', ['$path', ...command.split(' ')]);
    final lineStream =
        process.stdout.transform(Utf8Decoder()).transform(LineSplitter());

    // Test output is expected
    expect(
      lineStream,
      emitsInOrder([
        // Lines of output
        ...output,
        // Assert that the stream emits a done event and nothing else
        emitsDone
      ]),
    );

    // Pipe the error output and exit code (if any)
    await process.stderr.pipe(stderr);
    var code = await process.exitCode;
    if (code != 0) {
      print('exit code: $code');
    }
  });
}
