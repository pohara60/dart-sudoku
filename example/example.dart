import 'package:sudoku/sudoku.dart';

void main() {
  // final sudoku = Sudoku();
  // var str = sudoku.getSudoku();

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
  // var sudoku1 = Sudoku.sudoku(puzzle1);
  // print(sudoku1.invokeAllStrategies(true, false));

  var puzzle2 =
      // XYZ Wing, not solved until XY-Chain
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

  var puzzle3 =
      // Singles Chains
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
  ].join('\n');
  // var sudoku3 = Sudoku.sudoku(puzzle3);
  // print(sudoku3.invokeAllStrategies(true, false));
}
