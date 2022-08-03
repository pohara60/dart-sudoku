import 'dart:convert';
import 'dart:io';

import 'package:sudoku/sudoku.dart';
import 'package:test/test.dart';

void main() {
  group('API', () {
    final sudoku = Sudoku();
    test('getSudoku', () {
      expect(
        sudoku.getSudoku(),
        '1...2....\n.6...852.\n28...97..\n...3...6.\n.5...69..\n....9..4.\n......6..\n.9.....57\n..6..7.89',
      );
    });
    test('getSudoku', () {
      expect(sudoku.getSudoku(),
          '.....123.\n123..8.4.\n8.4..765.\n765......\n.........\n......123\n.123..8.4\n.8.4..765\n.765.....');
    });
    test('getSolutions', () {
      expect(sudoku.getSolutions(null), {
        '.....123.\n123..8.4.\n8.4..765.\n765......\n.........\n......123\n.123..8.4\n.8.4..765\n.765.....'
      });
    });
  });

  group('Command line', () {
    test_command('getSudoku', [
      'getSudoku = 1...2....',
      '.6...852.',
      '28...97..',
      '...3...6.',
      '.5...69..',
      '....9..4.',
      '......6..',
      '.9.....57',
      '..6..7.89',
    ]);
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
