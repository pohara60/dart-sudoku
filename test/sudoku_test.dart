import 'dart:convert';
import 'dart:io';

import 'package:sudoku/sudoku.dart';
import 'package:test/test.dart';

void main() {
  // group('API', () {
  //   test('sudoku1', () {
  //     var puzzle1 = [
  //       "72.4.8.3.",
  //       ".8.....47",
  //       "4.1.768.2",
  //       "81.739...",
  //       "...851...",
  //       "...264.8.",
  //       "2.968.413",
  //       "34......8",
  //       "168943275"
  //     ].join('\n');
  //     var sudoku1 = Sudoku.sudoku(puzzle1);
  //     expect(
  //       sudoku1.invokeAllStrategies(true, false),
  //       '1...2....\n.6...852.\n28...97..\n...3...6.\n.5...69..\n....9..4.\n......6..\n.9.....57\n..6..7.89',
  //     );
  //   });
  // });

  group('Command line', () {
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
    test_command('solution $puzzle1', []);
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
