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
  var sudoku = Sudoku.sudoku(puzzle);
  print(sudoku.invokeAllStrategies(true, false));

  var puzzle2 =
      // XYZ Wing, not solved
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
  var sudoku2 = Sudoku.sudoku(puzzle2);
  print(sudoku2.invokeAllStrategies(true, false));
}
