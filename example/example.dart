import 'package:sudoku/sudokuAPI.dart';

// ignore_for_file: unused_local_variable
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
  var killerPuzzle3 = [
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
  // Extremely Tough
  var killerPuzzle4 = [
    [24, LL, 08, 18, 14, LL, LL, LL, 21],
    [UU, UU, UU, UU, 13, LL, LL, RR, UU],
    [10, 15, UU, UU, 12, LL, 12, LL, LL],
    [UU, UU, 18, LL, 09, LL, 19, 13, LL],
    [10, 15, LL, UU, 17, 18, UU, LL, UU],
    [UU, LL, UU, RR, UU, UU, LL, 07, 12],
    [14, LL, LL, 05, LL, 21, 12, UU, UU],
    [13, LL, 07, LL, LL, UU, UU, 18, LL],
    [UU, 30, LL, LL, LL, UU, UU, UU, UU],
  ];
  var killerPuzzle5 = [
    [XX, XX, 13, LL, XX, 14, LL, XX, XX],
    [XX, XX, 18, LL, 07, LL, LL, XX, XX],
    [08, 17, XX, UU, 09, LL, XX, 07, 10],
    [UU, UU, 11, XX, UU, XX, RR, UU, UU],
    [XX, RR, UU, LL, XX, 24, LL, LL, XX],
    [15, 20, LL, XX, 18, XX, 06, LL, 12],
    [UU, UU, XX, 08, UU, 15, XX, UU, UU],
    [XX, XX, RR, UU, UU, UU, LL, XX, XX],
    [XX, XX, 08, LL, XX, 08, LL, XX, XX],
  ];
  var killerPuzzle = [
    [11, LL, XX, 11, 11, 11, XX, XX, XX],
    [XX, XX, 45, UU, UU, UU, 45, XX, XX],
    [XX, RR, UU, 11, LL, RR, UU, 11, LL],
    [11, LL, UU, XX, XX, XX, UU, XX, XX],
    [XX, UU, UU, XX, XX, 11, UU, XX, XX],
    [XX, XX, UU, RR, RR, UU, UU, XX, XX],
    [11, RR, UU, LL, XX, RR, UU, LL, XX],
    [UU, XX, XX, 11, XX, 11, 11, LL, XX],
    [XX, 11, LL, UU, XX, UU, UU, XX, XX],
  ];
  var whisperPuzzle = [
    ['R2C3', 'R3C3', 'R4C3', 'R5C3', 'R6C3'],
    ['R2C7', 'R3C7', 'R4C7', 'R5C7', 'R6C7', 'R7C7'],
    ['R6C9', 'R7C9'],
  ];
  // var puzzle = SudokuAPI.killer(emptySudoku, killerPuzzle, true);
  // print(puzzle.addWhisper(whisperPuzzle));
  // print(puzzle.solve(true, false));

  var sudokuPuzzle = [
    "8..3.....",
    ".........",
    ".........",
    "........6",
    ".........",
    "5........",
    ".........",
    ".........",
    ".....7..1",
  ].join('\n');
  var arrowPuzzle = [
    ['R3C2', 'R3C3', 'R3C4', 'R3C5'],
    ['R3C7', 'R2C7', 'R1C7'],
    ['R4C3', 'R4C4', 'R4C5', 'R4C6'],
    ['R5C4', 'R5C5', 'R5C6', 'R5C7'],
    ['R6C2', 'R7C2', 'R8C2', 'R9C2'],
    ['R6C9', 'R6C8', 'R6C7', 'R6C6'],
    ['R7C8', 'R7C7', 'R7C6', 'R7C5'],
    ['R8C7', 'R8C6', 'R8C5', 'R8C4'],
  ];
  // 6 not in arrows in B9 because 123 in B7: region combination is same as another cell in unit
  // 6 must go in R5 in B5, so arrow must have 6 - need mandatory values in region
  // Arrows in B9 cannot both have 1, so one of them is 234=9, and other is 7/8
  // Many arrows in a unit means minimum sum affects totals
  var puzzle = SudokuAPI.sudoku(sudokuPuzzle);
  print(puzzle.addArrow(arrowPuzzle));
  print(puzzle.solve(true, false));

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
  // var sudoku1 = SudokuAPI.sudoku(puzzle1);
  // print(sudoku1.solve(true, false));

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
  // var sudoku2 = SudokuAPI.sudoku(puzzle2);
  // print(sudoku2.solve(true, false));

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
  // var sudoku3 = SudokuAPI.sudoku(puzzle3);
  // print(sudoku3.solve(true, false));

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
  var sudoku4 = SudokuAPI.sudoku(puzzle4);
  // sudoku4.addKiller('KillerString');
  // print(sudoku4.solve(true, false));
}
