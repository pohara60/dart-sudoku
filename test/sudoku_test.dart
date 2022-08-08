import 'dart:convert';
import 'dart:io';

import 'package:sudoku/sudoku.dart';
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
  ].join('\n');
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
    'Hidden Single, R1C9 = 6',
    'Hidden Single, R2C1 = 9',
    'Hidden Single, R2C5 = 1',
    'Hidden Single, R2C6 = 2',
    'Hidden Single, R2C7 = 5',
    'Hidden Single, R3C4 = 5',
    'Hidden Single, R4C3 = 2',
    'Hidden Single, R4C7 = 6',
    'Hidden Single, R4C9 = 4',
    'Hidden Single, R5C2 = 7',
    'Hidden Single, R5C3 = 4',
    'Hidden Single, R5C7 = 3',
    'Hidden Single, R6C1 = 5',
    'Hidden Single, R8C5 = 2',
    'Hidden Single, R8C7 = 9',
    'Solved!',
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
  ].join('\n');
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
    'Pointing Group, B4, C3, remove group 56 from R7C3 = 138',
    'Pointing Group, B4, C3, remove group 56 from R8C3 = 1238',
    'Pointing Group, B4, C3, remove group 56 from R9C3 = 128',
    'Line Box Reduction, B6, C9, remove group 1 from R4C7 = 67',
    'Line Box Reduction, B6, C9, remove group 1 from R5C8 = 467',
    'XYZ-Wing, R hinge R5C8 B6], remove value 6 from R5C9 = 19',
    '6.......8',
    '5..9.8..7',
    '82...1.3.',
    '34.2.9.8.',
    '2...8.3..',
    '18.3.7.25',
    '75.4...92',
    '9....5..4',
    '4...9...3',
  ];
  group('API', () {
    test('sudoku1', () {
      var sudoku1 = Sudoku.sudoku(puzzle1);
      expect(
        sudoku1.invokeAllStrategies(true, false),
        solution1.join('\n'),
      );
    });
    test('sudoku2', () {
      var sudoku2 = Sudoku.sudoku(puzzle2);
      expect(
        sudoku2.invokeAllStrategies(true, false),
        solution2.join('\n'),
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
