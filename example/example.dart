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
  // var puzzle = SudokuAPI.killer(emptySudoku, killerPuzzle5, true);
  // puzzle.addSudokuX();
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  var killerPuzzle6 = [
    [08, LL, XX, XX, 22, XX, XX, 10, LL],
    [UU, XX, XX, RR, UU, XX, XX, XX, UU],
    [XX, 15, LL, XX, XX, 18, LL, XX, XX],
    [XX, UU, XX, 06, LL, XX, UU, XX, XX],
    [XX, XX, XX, UU, XX, XX, XX, XX, XX],
    [XX, 20, LL, XX, XX, XX, 20, LL, XX],
    [XX, UU, 20, XX, XX, XX, 20, UU, XX],
    [XX, RR, UU, XX, XX, XX, UU, LL, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
  ];
  // Not solved!
  // var puzzle = SudokuAPI.killer(emptySudoku, killerPuzzle6, true);
  // print(puzzle.solve(true, false));

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
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  var whisperPuzzle2 = [
    [
      'R4C4',
      'R4C5',
      'R5C6',
      'R6C7',
      'R6C8',
      'R6C9',
      'R5C9',
      'R4C9',
      'R4C8',
      'R3C9',
      'R2C8',
      'R3C7',
      'R3C6',
      'R3C5',
      'R2C4',
      'R2C3',
      'R2C2',
      'R3C2',
      'R4C1',
      'R5C2',
      'R6C1',
      'R6C2',
      'R6C3',
      'R6C4',
      'R7C3',
      'R8C3',
      'R8C2',
      'R8C1',
      'R9C1',
    ],
  ];
  var thermoPuzzle4 = [
    ['R9C7', 'R9C8'],
  ];
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addSudokuX());
  // print(puzzle.addThermo(thermoPuzzle4));
  // print(puzzle.addWhisper(whisperPuzzle2));
  // puzzle.debug = true;
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
  var arrowPuzzle1 = [
    ['R3C2', 'R3C3', 'R3C4', 'R3C5'],
    ['R3C7', 'R2C7', 'R1C7'],
    ['R4C3', 'R4C4', 'R4C5', 'R4C6'],
    ['R5C4', 'R5C5', 'R5C6', 'R5C7'],
    ['R6C2', 'R7C2', 'R8C2', 'R9C2'],
    ['R6C9', 'R6C8', 'R6C7', 'R6C6'],
    ['R7C8', 'R7C7', 'R7C6', 'R7C5'],
    ['R8C7', 'R8C6', 'R8C5', 'R8C4'],
  ];
  // var puzzle = SudokuAPI.sudoku(sudokuPuzzle);
  // print(puzzle.addArrow(arrowPuzzle1));
  // print(puzzle.solve(true, false));

  var thermoPuzzle1 = [
    ['R1C6', 'R1C7', 'R1C8', 'R2C8', 'R3C8', 'R4C8'],
    ['R2C6', 'R3C6', 'R4C6', 'R4C7'],
    ['R3C4', 'R2C4', 'R2C3', 'R2C2', 'R3C2', 'R4C2', 'R5C2', 'R5C3', 'R5C4'],
    ['R6C4', 'R7C4', 'R8C4', 'R8C3', 'R8C2', 'R7C2'],
    ['R7C6', 'R8C6', 'R9C6'],
    ['R9C7', 'R9C8', 'R8C8', 'R7C8', 'R6C8', 'R6C7', 'R6C6'],
  ];
  var thermoPuzzle2 = [
    ['R1C6', 'R2C6'],
    ['R1C7', 'R1C8', 'R2C8', 'R3C8', 'R3C7', 'R3C6'],
    ['R4C4', 'R3C4', 'R2C4', 'R1C4', 'R1C3', 'R1C2'],
    ['R4C4', 'R4C3', 'R4C2', 'R4C1', 'R3C1', 'R2C1', 'R1C1'],
    ['R5C5', 'R5C6', 'R5C7', 'R5C8', 'R5C9'],
    ['R5C5', 'R6C5', 'R7C5', 'R8C5'],
    ['R7C3', 'R6C3'],
    ['R8C1', 'R7C1', 'R6C1', 'R6C2'],
    ['R8C2', 'R8C3'],
    ['R8C9', 'R7C9', 'R6C9'],
    ['R8C9', 'R9C9', 'R9C8', 'R9C7', 'R9C6', 'R9C5'],
  ];

  var thermoSudoku3 = [
    ".........",
    ".........",
    ".........",
    "..8......",
    ".........",
    ".........",
    ".....1...",
    ".........",
    ".........",
  ].join('\n');
  var thermoPuzzle3 = [
    ['R1C6', 'R2C6', 'R3C6', 'R4C6', 'R5C6'],
    ['R1C7', 'R2C7', 'R3C7', 'R4C7', 'R5C7'],
    ['R1C8', 'R2C8', 'R3C8', 'R4C8'],
    ['R1C9', 'R2C9', 'R3C9'],
    ['R9C4', 'R8C4', 'R7C4', 'R6C4', 'R5C4'],
    ['R9C3', 'R8C3', 'R7C3', 'R6C3', 'R5C3'],
    ['R9C2', 'R8C2', 'R7C2', 'R6C2'],
    ['R9C1', 'R8C1', 'R7C1'],
  ];
  // var puzzle = SudokuAPI.sudoku(thermoSudoku3);
  // print(puzzle.addThermo(thermoPuzzle3));
  // print(puzzle.addChess(kingsMove: true));
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  const dd = ' ';
  const DX = 'X';
  const DV = 'V';
  const DO = 'O';
  const DE = 'E';
  const DC = 'C';
  const DM = 'M';
  var emptyDomino = [
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
  ];
  var dominoPuzzle1 = [
    [XX, DC, XX, dd, XX, dd, XX, dd, XX, dd, XX, DM, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, DC, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [DC, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [DM, dd, DM, dd, dd, dd, DC, dd, dd, dd, DM, dd, dd, dd, dd, dd, dd],
    [XX, DM, XX, DC, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DC, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DM, XX, DC, XX],
    [dd, dd, DC, dd, DM, dd, dd, dd, dd, dd, dd, dd, DC, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, DC, XX, DM, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DC, XX, dd, XX, dd, XX],
    [DC, dd, DC, dd, dd, dd, dd, dd, DC, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DC, XX, dd, XX, DM, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, DC, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DC, XX],
  ];
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addDomino(dominoPuzzle1, true));
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  var dominoPuzzle2 = [
    [XX, dd, XX, DO, XX, dd, XX, dd, XX, dd, XX, dd, XX, DE, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, DO, dd, dd, dd, DE, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, DO, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, DO, XX, DO, XX, dd, XX, dd, XX, dd, XX, dd, XX, DO, XX, DO, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, DE, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, DE, dd, dd, dd, DO, dd, dd, dd, DO, dd, dd, dd, DE, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, DO, dd, dd, dd, DE, dd, dd, dd, DO, dd, dd, dd, dd],
    [XX, DE, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DE, XX],
    [dd, dd, dd, dd, dd, dd, DE, dd, dd, dd, DO, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [DE, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, DO],
    [XX, dd, XX, DE, XX, dd, XX, dd, XX, dd, XX, dd, XX, DE, XX, dd, XX],
  ];
  var dominoKiller2 = [
    [XX, XX, XX, 23, LL, LL, XX, XX, XX],
    [XX, 15, XX, XX, UU, XX, XX, 15, XX],
    [RR, UU, 09, 07, LL, LL, 11, UU, LL],
    [XX, 12, UU, 28, XX, DD, UU, 16, XX],
    [RR, UU, XX, UU, LL, LL, XX, UU, LL],
    [XX, XX, 25, XX, UU, XX, 25, XX, XX],
    [14, LL, UU, XX, 22, XX, UU, 16, LL],
    [XX, UU, UU, RR, UU, LL, UU, UU, XX],
    [XX, RR, UU, XX, XX, XX, UU, LL, XX],
  ];
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addKiller(dominoKiller2, true));
  // print(puzzle.addDomino(dominoPuzzle2, false));
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  var dominoPuzzle3 = [
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, DV, XX, dd, XX, dd, XX, dd, XX, dd, XX, DV, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, DV, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, DX, XX, dd, XX, dd, XX, dd, XX, dd, XX, DX, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, DX, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, DV, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, DX, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DX, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
  ];
  var sandwichPuzzle3 = [
    ['C2', 3],
    ['C5', 6],
    ['C7', 25],
    ['C8', 9],
    ['R1', 30],
    ['R2', 5],
    ['R3', 4],
    ['R5', 10],
    ['R7', 30],
    ['R8', 15],
    ['R9', 4],
  ];
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addDomino(dominoPuzzle3, false));
  // print(puzzle.addSandwich(sandwichPuzzle3));
  // print(puzzle.solve(true, false));

  var dominoPuzzle4 = [
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, DC, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, DC, dd, dd, dd, dd, dd, dd],
    [XX, DM, XX, DC, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [DM, dd, dd, dd, DC, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, DC, XX, DC, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, DM, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, DM, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, DC, XX, dd, XX, dd, XX, DC, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, DM],
    [XX, dd, XX, DM, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, DC, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
  ];
  var whisperPuzzle4 = [
    ['R3C9', 'R4C8', 'R4C7', 'R3C7', 'R3C8', 'R4C9'],
    ['R5C3', 'R6C2', 'R6C1', 'R5C1', 'R5C2', 'R6C3'],
  ];
  var renbanPuzzle4 = [
    ['R1C8', 'R1C7', 'R2C6', 'R1C6', 'R2C7'],
    ['R2C4', 'R2C3', 'R3C2', 'R2C2', 'R3C3'],
    ['R5C7', 'R5C6', 'R6C5', 'R5C5', 'R6C6'],
    ['R7C3', 'R7C2', 'R8C1', 'R7C1', 'R8C2'],
  ];
  var thermoPuzzle5 = [
    ['R8C5', 'R7C6', 'R8C7', 'R9C8', 'R8C8', 'R9C7', 'R9C6', 'R9C5'],
  ];
  // Seven Fish Pie https://www.youtube.com/watch?v=C1jOI3gBnV4&t=2272s
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addDomino(dominoPuzzle4, false));
  // print(puzzle.addWhisper(whisperPuzzle4));
  // print(puzzle.addRenban(renbanPuzzle4));
  // print(puzzle.addThermo(thermoPuzzle5));
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  // Difficult "Handshake" puzzle
  // Needs deduction about matching cells
  var arrowPuzzle2 = [
    ['R1C2', 'R2C1', 'R3C2'],
    ['R1C3', 'R2C3', 'R3C3'],
    ['R1C3', 'R2C4'],
    ['R1C8', 'R1C7', 'R2C7'],
    ['R3C7', 'R2C6', 'R1C6'],
    ['R4C2', 'R3C3'],
    ['R4C2', 'R5C3', 'R5C3'],
    ['R5C6', 'R5C5', 'R4C5'],
    ['R5C6', 'R4C7'],
    ['R6C1', 'R7C2'],
    ['R7C1', 'R6C2'],
    ['R7C1', 'R8C1', 'R9C1'],
    ['R7C4', 'R6C5', 'R5C4'],
    ['R7C7', 'R7C8', 'R7C9'],
    ['R7C7', 'R8C6', 'R9C6'],
    ['R9C4', 'R8C3'],
    ['R9C4', 'R9C5', 'R8C5'],
    ['R9C9', 'R9C8', 'R9C7'],
  ];
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addArrow(arrowPuzzle2));
  // print(puzzle.solve(true, false));

  var arrowKiller3 = [
    [XX, XX, XX, XX, 10, XX, XX, 07, LL],
    [XX, XX, XX, XX, UU, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, 16, LL, LL],
    [10, LL, XX, XX, 15, LL, LL, XX, XX],
    [XX, XX, XX, XX, UU, XX, XX, XX, XX],
    [XX, XX, XX, 08, UU, XX, XX, XX, XX],
    [14, XX, XX, UU, XX, XX, XX, 18, LL],
    [UU, XX, XX, UU, XX, XX, XX, UU, UU],
  ];
  var arrowPuzzle3 = [
    ['R3C3', 'R2C4', 'R1C4'],
    ['R3C3', 'R4C2', 'R4C1'],
    ['R3C3', 'R4C4'],
    ['R3C7', 'R2C6', 'R1C6'],
    ['R3C7', 'R4C6'],
    ['R7C3', 'R6C2', 'R6C1'],
    ['R7C3', 'R6C4'],
    ['R7C8', 'R6C9', 'R5C8'],
    ['R8C7', 'R9C6', 'R8C5'],
  ];
  // Difficult puzzle requires intersection of Row and Box with
  // Arrow and Killer regions
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addKiller(arrowKiller3, true));
  // print(puzzle.addArrow(arrowPuzzle3));
  // // Attempt complex Mixed Regions
  // puzzle.addMixedRegionGroupByName(
  //     ['B2', 'A1', 'A4', 'K1', 'R3', 'A3', 'A5', 'C4']);
  // puzzle.addMixedRegionGroupByName(['B4', 'A2', 'A6', 'K4', 'C3', 'A3', 'A7']);
  // puzzle.addMixedRegionGroupByName(['C3', 'C5', 'R3', 'R5', 'K5']);
  // // Still no solutiom
  // print(puzzle.solve(true, false));
  var arrowKiller4 = [
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, 10, LL],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, XX, XX, XX, XX, XX, XX],
    [XX, XX, XX, 06, LL, XX, XX, XX, XX],
  ];
  var arrowPuzzle4 = [
    ['R1C6', 'R2C7', 'R3C7'],
    ['R1C9', 'R2C8', 'R3C8'],
    ['R2C1', 'R1C2', 'R1C3'],
    ['R3C3', 'R3C4', 'R3C5', 'R2C5'],
    ['R4C1', 'R5C1', 'R6C1'],
    ['R4C6', 'R5C5', 'R5C4'],
    ['R4C9', 'R5C9', 'R6C9'],
    ['R6C3', 'R7C4', 'R6C5'],
    ['R8C1', 'R8C2', 'R8C3'],
    ['R8C9', 'R8C8', 'R8C7'],
  ];
  var sandwichPuzzle4 = [
    ['C1', 17],
    ['C3', 10],
    ['R1', 15],
    ['R4', 22],
    ['R8', 12],
  ];
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addKiller(arrowKiller4, true));
  // print(puzzle.addArrow(arrowPuzzle4));
  // print(puzzle.addSandwich(sandwichPuzzle4));
  // puzzle.addMixedRegionGroupByName(['SC1', 'A3', 'A5', 'A9']);
  // puzzle.addMixedRegionGroupByName(['SC3', 'A3', 'A4', 'A8', 'A9']);
  // puzzle.addMixedRegionGroupByName(['SR1', 'A1', 'A2', 'A3']);
  // puzzle.addMixedRegionGroupByName(['SR4', 'A5', 'A6', 'A7']);
  // puzzle.addMixedRegionGroupByName(['SR8', 'A9', 'A10']);
  // print(puzzle.solve(true, false));

  var renbanSudokuPuzzle = [
    ".........",
    ".........",
    "......1..",
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
  ].join('\n');
  var renbanDomino = [
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DM, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, DM],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, DM, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, DM, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
  ];
  var renbanPuzzle = [
    ['R2C1', 'R1C1', 'R1C2', 'R1C3'],
    ['R1C4', 'R1C5', 'R1C6', 'R2C6'],
    ['R2C3', 'R2C4', 'R3C4', 'R4C4'],
    ['R3C1', 'R4C1', 'R5C1', 'R5C2'],
    ['R4C8', 'R4C9', 'R5C9', 'R6C9'],
    ['R5C4', 'R5C3', 'R6C3', 'R7C3'],
    ['R5C5', 'R5C6', 'R6C6', 'R7C6'],
    ['R6C7', 'R7C7', 'R8C7', 'R8C6'],
    ['R7C1', 'R8C1', 'R9C1', 'R9C2'],
    ['R7C4', 'R8C4', 'R9C4', 'R9C3'],
    ['R7C9', 'R8C9', 'R9C9', 'R9C8'],
  ];
  // var puzzle = SudokuAPI.sudoku(renbanSudokuPuzzle);
  // print(puzzle.addDomino(renbanDomino));
  // print(puzzle.addRenban(renbanPuzzle));
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  var chessSudoku1 = [
    ".........",
    "7.......8",
    "..12345..",
    "3.......6",
    "....8....",
    "1.......4",
    "..45678..",
    "9.......2",
    ".........",
  ].join('\n');
  // var puzzle = SudokuAPI.sudoku(chessSudoku1);
  // puzzle.debug = true;
  // print(puzzle.addChess(knightsMove: true));
  // print(puzzle.solve(true, false));

  var chessSudoku2 = [
    "123......",
    "45.......",
    "7.9......",
    "...1.3...",
    "...4.6...",
    "...7.9...",
    "......1.3",
    "......456",
    ".......89",
  ].join('\n');
  // var puzzle = SudokuAPI.sudoku(chessSudoku2);
  // puzzle.debug = true;
  // print(puzzle.addChess(knightsMove: true));
  // print(puzzle.solve(true, false));

  var entropySudokuPuzzle = [
    ".........",
    ".........",
    ".....1...",
    "......6..",
    ".........",
    "..9....8.",
    "4........",
    "......2..",
    ".........",
  ].join('\n');
  var entropyPuzzle = [
    [
      'R5C3',
      'R4C2',
      'R4C3',
      'R3C2',
      'R3C3',
      'R2C2',
      'R1C1',
      'R2C1',
      'R3C1',
      'R4C1',
      'R5C1',
      'R6C1',
      'R6C2',
      'R7C3',
      'R8C2',
      'R9C1',
      'R9C2',
      'R9C3',
      'R9C4',
      'R8C4',
      'R8C5',
      'R7C5',
      'R7C4',
      'R6C4',
      'R5C4',
      'R4C4',
      'R3C4'
    ],
    [
      'R1C4',
      'R2C4',
      'R1C5',
      'R2C5',
      'R1C6',
      'R1C7',
      'R1C8',
      'R1C9',
      'R2C8',
      'R3C7',
      'R4C8',
      'R4C9',
      'R5C9',
      'R6C9',
      'R7C9',
      'R8C9',
      'R9C9',
      'R8C8',
      'R7C7',
      'R6C7',
      'R5C7',
      'R6C6',
      'R5C5',
      'R5C6',
      'R4C6',
      'R4C5',
      'R3C5'
    ]
  ];
  // Entropic Lines 101 https://logic-masters.de/Raetselportal/Raetsel/zeigen.php?id=0008W3
  // var puzzle = SudokuAPI.sudoku(entropySudokuPuzzle);
  // print(puzzle.addEntropy(entropyPuzzle));
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  var regionSumSudokuPuzzle1 = [
    "1........",
    ".........",
    ".........",
    ".........",
    ".........",
    "........4",
    ".........",
    ".........",
    ".....5..3",
  ].join('\n');
  var regionSumPuzzle1 = [
    ['R1C4', 'R2C4', 'R3C4', 'R3C5', 'R4C5', 'R4C6', 'R3C6', 'R2C6', 'R2C5'],
    ['R1C5', 'R1C6', 'R1C7', 'R2C7', 'R3C7', 'R2C8', 'R2C9'],
    ['R3C3', 'R4C4', 'R5C5', 'R6C6', 'R7C7'],
    ['R4C1', 'R4C2', 'R4C3', 'R5C3', 'R5C4', 'R6C4', 'R6C3', 'R6C2', 'R5C2'],
    ['R5C1', 'R6C1', 'R7C1', 'R7C2', 'R7C3', 'R8C2', 'R9C2'],
    ['R6C7', 'R7C8', 'R7C9'],
    ['R7C5', 'R7C6', 'R8C7'],
  ];
  // Puzzle requires logic that cannot yet be implemetnted
  // var puzzle = SudokuAPI.sudoku(regionSumSudokuPuzzle1);
  // print(puzzle.addRegionSum(regionSumPuzzle1));
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  var regionSumSudokuPuzzle2 = [
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
    ".........",
    "...7.....",
  ].join('\n');
  var regionSumPuzzle2 = [
    ['R1C1', 'R2C1', 'R3C2', 'R4C2', 'R4C3', 'R4C4'],
    ['R1C4', 'R1C5', 'R1C6', 'R1C7', 'R1C8'],
    ['R1C9', 'R2C8', 'R3C8', 'R4C8', 'R4C7', 'R4C6'],
    ['R2C6', 'R3C6', 'R4C5'],
    ['R2C9', 'R3C9', 'R4C9', 'R5C9'],
    ['R5C3', 'R5C2', 'R6C1', 'R7C2', 'R8C2'],
    ['R5C5', 'R6C5', 'R7C5', 'R7C4', 'R8C4'],
    ['R6C4', 'R6C3', 'R6C2', 'R7C1', 'R8C1', 'R9C1'],
    ['R6C6', 'R6C7', 'R6C8', 'R7C8', 'R8C9', 'R9C9'],
    ['R8C6', 'R9C7', 'R9C8'],
    ['R9C2', 'R9C3', 'R9C4', 'R9C5', 'R9C6'],
  ];
  // var puzzle = SudokuAPI.sudoku(regionSumSudokuPuzzle2);
  // print(puzzle.addRegionSum(regionSumPuzzle2));
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

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

  // "XV Kropki X" by Florian Wortmann
  // (Diagonal +/-, kropki no negative, XV with negative)
  var dominoPuzzle5 = [
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, DC, XX, DC, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, DC, dd, dd, dd, DV, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, DM, XX, dd, XX, dd, XX, DX, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DM, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, DM, dd, DC, dd, dd],
    [XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, DC, XX, dd, XX],
    [dd, dd, dd, dd, dd, dd, dd, dd, dd, dd, DC, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, DM, XX, dd, XX, dd, XX, DM, XX, DC, XX, dd, XX, dd, XX],
    [dd, dd, DC, dd, DC, dd, dd, dd, dd, dd, DC, dd, dd, dd, dd, dd, dd],
    [XX, dd, XX, DC, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX, dd, XX],
  ];
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addDomino(dominoPuzzle5, true, ['xv']));
  // print(puzzle.addSudokuX());
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));

  // Little Killer
  var littleKillerSudoku1 = [
    "....3....",
    ".2.....4.",
    "..8......",
    "...2.....",
    "9.......5",
    ".....6...",
    "......4..",
    ".8.....6.",
    "....7....",
  ].join('\n');
  var littleKillerPuzzle1 = [
    ['41', 'DR', 'R1C1'],
    ['09', 'DR', 'R1C7'],
    ['10', 'DR', 'R1C8'],
    ['09', 'UR', 'R2C1'],
    ['08', 'UR', 'R3C1'],
    ['10', 'DL', 'R7C9'],
    ['11', 'DL', 'R8C9'],
    ['12', 'UL', 'R9C2'],
    ['11', 'UL', 'R9C3'],
  ];
  var puzzle = SudokuAPI.sudoku(littleKillerSudoku1);
  print(puzzle.addLittleKiller(littleKillerPuzzle1));
  puzzle.debug = true;
  print(puzzle.solve(true, false));

  // Little Killer - not solvable
  var littleKillerPuzzle2 = [
    ['31', 'DR', 'R1C4'],
    ['31', 'DR', 'R1C5'],
    ['31', 'UR', 'R4C1'],
    ['31', 'UR', 'R5C1'],
    ['31', 'UR', 'R6C1'],
    ['31', 'UR', 'R7C1'],
    ['31', 'UR', 'R8C1'],
    ['31', 'UR', 'R9C1'],
    ['31', 'UR', 'R9C2'],
    ['31', 'DL', 'R6C9'],
  ];
  // var puzzle = SudokuAPI.sudoku(emptySudoku);
  // print(puzzle.addLittleKiller(littleKillerPuzzle2));
  // puzzle.debug = true;
  // print(puzzle.solve(true, false));
}
