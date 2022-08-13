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
  const LL = "L";
  const RR = "R";
  const UU = "U";
  const DD = "D";
  const XX = '.';

  var emptyKiller = [
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
  ];
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
  var killerPuzzle2 = [
    [13, 09, LL, 15, LL, LL, 13, 25, LL],
    [UU, 13, LL, 08, LL, RR, UU, UU, UU],
    [UU, 01, 17, 02, 11, LL, 09, LL, 10],
    [17, LL, UU, 28, LL, 16, LL, 10, UU],
    [UU, 13, UU, UU, UU, UU, UU, UU, LL],
    [24, UU, LL, 10, LL, LL, 23, LL, 17],
    [UU, LL, 05, LL, 06, LL, UU, RR, UU],
    [13, LL, 23, LL, 10, 18, 10, LL, 09],
    [UU, 07, LL, UU, UU, UU, LL, UU, UU],
  ];
  var killerPuzzle = [
    [11, LL, 08, 14, LL, 06, LL, 23, LL],
    [11, LL, UU, UU, 14, LL, 06, LL, UU],
    [18, 15, 11, LL, 08, 22, LL, UU, 12],
    [UU, UU, 42, UU, UU, UU, UU, 17, UU],
    [UU, UU, UU, 18, LL, 13, LL, UU, 07],
    [UU, 19, UU, UU, UU, 12, LL, RR, UU],
    [RR, UU, UU, LL, LL, LL, UU, 08, LL],
    [16, LL, 16, LL, 17, LL, LL, 09, 09],
    [UU, UU, UU, 23, LL, LL, LL, UU, UU],
  ];
  var killer = Sudoku.killer(emptySudoku, killerPuzzle);
  print(killer.invokeAllStrategies(true, false));

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
