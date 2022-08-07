import 'package:sudoku/sudoku.dart';

void main() {
  // final sudoku = Sudoku();
  // var str = sudoku.getSudoku();

  var puzzle = [
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
  print('getSudoku\n$puzzle');
  var sudoku = Sudoku.sudoku(puzzle);
  sudoku.invokeAllStrategies(true, false);
}
