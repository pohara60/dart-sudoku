import 'package:sudoku/sudoku.dart';

void main() {
  var emptySudoku = [
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
  ].join('\n');

  const L = "L";
  const R = "R";
  const U = "U";
  const D = "D";
  var killerPuzzle1 = [
    [8, L, 13, L, 18, L, L, 20, L],
    [21, L, 14, L, L, 17, U, U, U],
    [U, U, 23, L, R, U, 25, 18, 12],
    [20, L, U, 15, U, R, U, U, U],
    [U, U, 19, U, 10, 19, U, U, L],
    [R, R, U, U, U, U, 15, L, L],
    [13, 21, L, U, 20, U, 14, L, U],
    [U, U, 10, L, U, L, L, U, L],
    [U, U, 18, L, L, 6, L, 16, L],
  ];
  var killer1 = Sudoku.killer(emptySudoku, killerPuzzle1);
  print(killer1.invokeAllStrategies(true, false));

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
  // var sudoku2 = Sudoku.sudoku(puzzle2);
  // print(sudoku2.invokeAllStrategies(true, false));

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
  ].join('\n');
  var sudoku4 = Sudoku.sudoku(puzzle4);
  // sudoku4.addKiller('KillerString');
  // print(sudoku4.invokeAllStrategies(true, false));
}
