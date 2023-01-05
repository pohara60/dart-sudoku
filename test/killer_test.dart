import 'package:sudoku/sudokuAPI.dart';
import 'package:test/test.dart';

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

// ignore_for_file: unused_local_variable
  const L = "L";
  const R = "R";
  const U = "U";
  const D = "D";
  const LL = "L";
  const RR = "R";
  const UU = "U";
  const DD = "D";
  const XX = '.';

  var killerPuzzle1 = [
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
  var killerSolution1 = [
    'SudokuX',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m13\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m14\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m18\x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[45m 7\x1B[49m\x1B[39m\x1B[30m\x1B[45m  \x1B[49m\x1B[39m\x1B[30m\x1B[45m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[42m 8\x1B[49m\x1B[39m\x1B[30m\x1B[43m17\x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 9\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 7\x1B[49m\x1B[39m\x1B[30m\x1B[43m10\x1B[49m\x1B[39m',
    '\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m11\x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m24\x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[42m15\x1B[49m\x1B[39m\x1B[30m\x1B[43m20\x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m18\x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 6\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m12\x1B[49m\x1B[39m',
    '\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m 8\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m15\x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 8\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 8\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '.........',
    '.........',
    '.........',
    '.........',
    '.........',
    '.........',
    '.........',
    '.........',
    '.........',
    'Region Combinations, K1 13:R1C3-4, R1C3 = 456789',
    'Region Combinations, K1 13:R1C3-4, R1C4 = 456789',
    'Region Combinations, K2 14:R1C6-7, R1C6 = 5689',
    'Region Combinations, K2 14:R1C6-7, R1C7 = 5689',
    'Region Combinations, K4 7:R2C5-7, R2C5 = 124',
    'Region Combinations, K4 7:R2C5-7, R2C6 = 124',
    'Region Combinations, K4 7:R2C5-7, R2C7 = 124',
    'Region Combinations, K5 8:R3-4C1, R3C1 = 123567',
    'Region Combinations, K5 8:R3-4C1, R4C1 = 123567',
    'Region Combinations, K6 17:R3-4C2, R3C2 = 89',
    'Region Combinations, K6 17:R3-4C2, R4C2 = 89',
    'Region Combinations, K7 9:R3C5-6,R4C5, R3C5 = 123456',
    'Region Combinations, K7 9:R3C5-6,R4C5, R3C6 = 123456',
    'Region Combinations, K7 9:R3C5-6,R4C5, R4C5 = 123456',
    'Region Combinations, K8 7:R3-4C8,R4C7, R3C8 = 124',
    'Region Combinations, K8 7:R3-4C8,R4C7, R4C8 = 124',
    'Region Combinations, K8 7:R3-4C8,R4C7, R4C7 = 124',
    'Region Combinations, K9 10:R3-4C9, R3C9 = 12346789',
    'Region Combinations, K9 10:R3-4C9, R4C9 = 12346789',
    'Region Combinations, K10 11:R4-5C3,R5C4,R5C2, R4C3 = 1235',
    'Region Combinations, K10 11:R4-5C3,R5C4,R5C2, R5C3 = 1235',
    'Region Combinations, K10 11:R4-5C3,R5C4,R5C2, R5C4 = 1235',
    'Region Combinations, K10 11:R4-5C3,R5C4,R5C2, R5C2 = 1235',
    'Region Combinations, K11 24:R5C6-8, R5C6 = 789',
    'Region Combinations, K11 24:R5C6-8, R5C7 = 789',
    'Region Combinations, K11 24:R5C6-8, R5C8 = 789',
    'Region Combinations, K12 15:R6-7C1, R6C1 = 6789',
    'Region Combinations, K12 15:R6-7C1, R7C1 = 6789',
    'Region Combinations, K13 20:R6C2-3,R7C2, R6C2 = 3456789',
    'Region Combinations, K13 20:R6C2-3,R7C2, R6C3 = 3456789',
    'Region Combinations, K13 20:R6C2-3,R7C2, R7C2 = 3456789',
    'Region Combinations, K15 6:R6C7-8,R7C8, R6C7 = 123',
    'Region Combinations, K15 6:R6C7-8,R7C8, R6C8 = 123',
    'Region Combinations, K15 6:R6C7-8,R7C8, R7C8 = 123',
    'Region Combinations, K16 12:R6-7C9, R6C9 = 345789',
    'Region Combinations, K16 12:R6-7C9, R7C9 = 345789',
    'Region Combinations, K17 8:R7-8C4,R8C3, R7C4 = 12345',
    'Region Combinations, K17 8:R7-8C4,R8C3, R8C4 = 12345',
    'Region Combinations, K17 8:R7-8C4,R8C3, R8C3 = 12345',
    'Region Combinations, K19 8:R9C3-4, R9C3 = 123567',
    'Region Combinations, K19 8:R9C3-4, R9C4 = 123567',
    'Region Combinations, K20 8:R9C6-7, R9C6 = 123567',
    'Region Combinations, K20 8:R9C6-7, R9C7 = 123567',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C1 = 12345678',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C2 = 12345678',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C5 = 12345678',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C8 = 12345678',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C9 = 12345678',
    'Region Combinations, KV2 38iR2:R2C1-4,R2C8-9, R2C1 = 356789',
    'Region Combinations, KV2 38iR2:R2C1-4,R2C8-9, R2C2 = 356789',
    'Region Combinations, KV2 38iR2:R2C1-4,R2C8-9, R2C3 = 356789',
    'Region Combinations, KV2 38iR2:R2C1-4,R2C8-9, R2C4 = 356789',
    'Region Combinations, KV2 38iR2:R2C1-4,R2C8-9, R2C8 = 356789',
    'Region Combinations, KV2 38iR2:R2C1-4,R2C8-9, R2C9 = 356789',
    'Region Combinations, KV3 21iR5:R5C1-5,R5C9, R5C1 = 123456',
    'Region Combinations, KV3 21iR5:R5C1-5,R5C9, R5C5 = 123456',
    'Region Combinations, KV3 21iR5:R5C1-5,R5C9, R5C9 = 123456',
    'Region Combinations, KV7 28iC2:R1-2C2,R5-9C2, R1C2 = 1234567',
    'Region Combinations, KV7 28iC2:R1-2C2,R5-9C2, R2C2 = 3567',
    'Region Combinations, KV7 28iC2:R1-2C2,R5-9C2, R6C2 = 34567',
    'Region Combinations, KV7 28iC2:R1-2C2,R5-9C2, R7C2 = 34567',
    'Region Combinations, KV7 28iC2:R1-2C2,R5-9C2, R8C2 = 1234567',
    'Region Combinations, KV7 28iC2:R1-2C2,R5-9C2, R9C2 = 1234567',
    'Naked Group, remove group 1234 from R4C9 = 6789',
    'Naked Group, remove group 1234 from R5C9 = 56',
    'Naked Group, remove group 1234 from R6C9 = 5789',
    'Naked Group, remove group 1234 from R1C8 = 5678',
    'Naked Group, remove group 1234 from R2C8 = 56789',
    'Naked Group, remove group 1234 from R8C8 = 56789',
    'Naked Group, remove group 1234 from R9C8 = 56789',
    'Pointing Group, B6,R4, remove group 4 from R4C4 = 12356789',
    'Pointing Group, B6,R4, remove group 4 from R4C5 = 12356',
    'Pointing Group, B6,R4, remove group 4 from R4C6 = 12356789',
    'Pointing Group, B6,R4, remove value 4 from K8 R3C8 = 12',
    'Pointing Group, B6,R6, remove group 3 from R6C2 = 4567',
    'Pointing Group, B6,R6, remove group 3 from R6C3 = 456789',
    'Pointing Group, B6,R6, remove group 3 from R6C4 = 12456789',
    'Pointing Group, B6,R6, remove group 3 from R6C5 = 12456789',
    'Pointing Group, B6,R6, remove group 3 from R6C6 = 12456789',
    'Pointing Group, B6,R6, remove value 3 from K15 R7C8 = 12',
    'Pointing Group, B6,C9, remove group 56 from R1C9 = 123478',
    'Pointing Group, B6,C9, remove group 56 from R2C9 = 3789',
    'Pointing Group, B6,C9, remove group 56 from R3C9 = 1234789',
    'Pointing Group, B6,C9, remove group 56 from R7C9 = 34789',
    'Pointing Group, B6,C9, remove group 56 from R8C9 = 1234789',
    'Pointing Group, B6,C9, remove group 56 from R9C9 = 1234789',
    'Hidden Single, R4C8 = 4',
    'Hidden Single, R6C8 = 3',
    'Naked Group, remove group 12 from R2C7 = 4',
    'Naked Group, remove group 12 from R3C7 = 3456789',
    'Naked Group, remove group 12 from R7C7 = 3456789',
    'Naked Group, remove group 12 from R8C7 = 3456789',
    'Naked Group, remove group 12 from R9C7 = 3567',
    'Naked Group, remove group 124 from R3C7 = 356789',
    'Naked Group, remove group 124 from R7C7 = 356789',
    'Naked Group, remove group 124 from R8C7 = 356789',
    'Naked Single, R2C7 = 4',
    'Naked Group, remove group 12 from R1C5 = 345678',
    'Naked Group, remove group 12 from R3C4 = 3456789',
    'Naked Group, remove group 12 from R3C5 = 3456',
    'Naked Group, remove group 12 from R3C6 = 3456',
    'Region Combinations, K7 9:R3C5-6,R4C5, R3C5 = 345',
    'Region Combinations, K7 9:R3C5-6,R4C5, R3C6 = 345',
    'Region Combinations, K7 9:R3C5-6,R4C5, R4C5 = 12',
    'Region Combinations, K9 10:R3-4C9, R3C9 = 123',
    'Region Combinations, K9 10:R3-4C9, R4C9 = 789',
    'Region Combinations, K13 20:R6C2-3,R7C2, R6C3 = 89',
    'Region Combinations, K13 20:R6C2-3,R7C2, R7C2 = 4567',
    'Region Combinations, K16 12:R6-7C9, R6C9 = 589',
    'Region Combinations, K16 12:R6-7C9, R7C9 = 347',
    'Region Combinations, K20 8:R9C6-7, R9C6 = 1235',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C1 = 1234567',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C5 = 34567',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C9 = 1237',
    'Region Combinations, KV8 27iC5:R1-5C5,R9C5, R1C5 = 4567',
    'Region Combinations, KV8 27iC5:R1-5C5,R9C5, R5C5 = 3456',
    'Region Combinations, KV8 27iC5:R1-5C5,R9C5, R9C5 = 89',
    'Hidden Single, R5C9 = 6',
    'Hidden Single, R6C9 = 5',
    'Naked Group, remove group 89 from R6C1 = 67',
    'Naked Group, remove group 12 from R4C1 = 3567',
    'Naked Group, remove group 12 from R4C3 = 35',
    'Naked Group, remove group 12 from R4C4 = 356789',
    'Naked Group, remove group 12 from R4C6 = 356789',
    'Naked Group, remove group 12 from R6C5 = 46789',
    'Naked Group, remove group 12 from R7C5 = 3456789',
    'Naked Group, remove group 12 from R8C5 = 3456789',
    'Hidden Group, set R1C1 = 123',
    'Hidden Group, set R1C2 = 123',
    'Hidden Group, set R1C9 = 123',
    'Naked Group, remove group 123 from R2C9 = 789',
    'Naked Group, remove group 123 from R3C7 = 56789',
    'Pointing Group, B1,C3, remove group 4 from R7C3 = 12356789',
    'Pointing Group, B1,C3, remove group 4 from R8C3 = 1235',
    'Pointing Group, B3,C9, remove group 3 from R7C9 = 47',
    'Pointing Group, B3,C9, remove group 3 from R8C9 = 124789',
    'Pointing Group, B3,C9, remove group 3 from R9C9 = 124789',
    'Pointing Group, B4,R5, remove group 12 from R5C4 = 35',
    'Region Combinations, K5 8:R3-4C1, R3C1 = 1235',
    'Region Combinations, K10 11:R4-5C3,R5C4,R5C2, R5C3 = 12',
    'Region Combinations, K10 11:R4-5C3,R5C4,R5C2, R5C2 = 12',
    'Region Combinations, K12 15:R6-7C1, R7C1 = 89',
    'Region Combinations, K13 20:R6C2-3,R7C2, R7C2 = 457',
    'Region Combinations, K16 12:R6-7C9, R7C9 = 7',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C5 = 457',
    'Region Combinations, KV1 18iR1:R1C1-2,R1C5,R1C8-9, R1C8 = 578',
    'Region Combinations, KV3 21iR5:R5C1-5,R5C9, R5C1 = 345',
    'Region Combinations, KV8 27iC5:R1-5C5,R9C5, R1C5 = 7',
    'Region Combinations, KV9 23iC9:R1-2C9,R5C9,R8-9C9, R1C9 = 3',
    'Region Combinations, KV9 23iC9:R1-2C9,R5C9,R8-9C9, R2C9 = 89',
    'Region Combinations, KV9 23iC9:R1-2C9,R5C9,R8-9C9, R8C9 = 124',
    'Region Combinations, KV9 23iC9:R1-2C9,R5C9,R8-9C9, R9C9 = 124',
    'Region Combinations, X2, R4C6 = 56789',
    'Region Combinations, X2, R5C5 = 45',
    'Region Combinations, X2, R7C3 = 1256789',
    'Region Combinations, X2, R8C2 = 124567',
    'Region Combinations, X2, R9C1 = 12456789',
    'Naked Single, R1C5 = 7',
    'Naked Single, R1C9 = 3',
    'Naked Single, R7C9 = 7',
    'Naked Group, remove group 12 from R3C1 = 35',
    'Naked Group, remove group 12 from R3C3 = 3456789',
    'Naked Group, remove group 345 from R3C3 = 6789',
    'Naked Group, remove group 345 from R3C4 = 689',
    'Naked Group, remove group 345 from R3C7 = 6789',
    'Naked Group, remove group 89 from R4C4 = 3567',
    'Naked Group, remove group 89 from R4C6 = 567',
    'Naked Group, remove group 12 from R8C2 = 4567',
    'Naked Group, remove group 12 from R9C2 = 34567',
    'Hidden Single, R1C3 = 4',
    'Pointing Group, B3,X2, remove group 7 from R4C6 = 56',
    'Pointing Group, B3,X2, remove group 7 from R6C4 = 124689',
    'Pointing Group, B3,X2, remove group 7 from R8C2 = 456',
    'Pointing Group, B3,X2, remove group 7 from R9C1 = 1245689',
    'Pointing Group, B5,C4, remove group 3 from R2C4 = 5689',
    'Pointing Group, B5,C4, remove group 3 from R7C4 = 1245',
    'Pointing Group, B5,C4, remove group 3 from R8C4 = 1245',
    'Pointing Group, B5,C4, remove group 3 from R9C4 = 12567',
    'Pointing Group, B6,R5, remove group 7 from R5C6 = 89',
    'Naked Group, remove group 456 from R2C8 = 789',
    'Naked Group, remove group 456 from R3C7 = 789',
    'Naked Group, remove group 456 from R6C4 = 1289',
    'Naked Group, remove group 456 from R7C3 = 1289',
    'Naked Group, remove group 456 from R9C1 = 1289',
    'Hidden Single, R1C7 = 6',
    'Hidden Single, R1C8 = 5',
    'Naked Group, remove group 89 from R2C4 = 56',
    'Naked Group, remove group 89 from R3C4 = 6',
    'Naked Group, remove group 689 from R2C4 = 5',
    'Naked Group, remove group 56 from R3C5 = 34',
    'Naked Group, remove group 56 from R3C6 = 34',
    'Naked Group, remove group 125 from R2C1 = 36789',
    'Naked Group, remove group 125 from R2C2 = 367',
    'Naked Group, remove group 125 from R2C3 = 36789',
    'Naked Group, remove group 34 from R3C1 = 5',
    'Naked Group, remove group 346 from R3C3 = 789',
    'Naked Group, remove group 56 from R4C4 = 37',
    'Naked Group, remove group 56 from R5C4 = 3',
    'Naked Group, remove group 56 from R7C4 = 124',
    'Naked Group, remove group 56 from R8C4 = 124',
    'Naked Group, remove group 56 from R9C4 = 127',
    'Naked Group, remove group 35 from R4C4 = 7',
    'Naked Group, remove group 567 from R9C4 = 12',
    'Naked Group, remove group 124 from R6C4 = 89',
    'Naked Group, remove group 89 from R6C6 = 12467',
    'Naked Group, remove group 89 from R7C6 = 123456',
    'Naked Group, remove group 89 from R8C6 = 1234567',
    'Naked Group, remove group 789 from R7C3 = 12',
    'Naked Group, remove group 789 from R9C1 = 12',
    'Naked Single, R2C4 = 5',
    'Naked Single, R3C1 = 5',
    'Naked Single, R3C4 = 6',
    'Naked Single, R4C4 = 7',
    'Naked Single, R5C4 = 3',
    'Hidden Single, R8C6 = 7',
    'Hidden Single, R3C7 = 7',
    'Hidden Single, R4C3 = 5',
    'Naked Single, R5C1 = 4',
    'Hidden Single, R5C5 = 5',
    'Hidden Single, R8C2 = 4',
    'Hidden Single, R4C1 = 3',
    'Naked Single, R4C6 = 6',
    'Hidden Single, R5C8 = 7',
    'Naked Single, R7C2 = 5',
    'Hidden Single, R7C4 = 4',
    'Hidden Single, R8C7 = 5',
    'Hidden Single, R9C9 = 4',
    'Hidden Single, R3C6 = 4',
    'Hidden Single, R6C5 = 4',
    'Hidden Single, R7C5 = 6',
    'Hidden Single, R9C6 = 5',
    'Naked Single, R9C7 = 3',
    'Hidden Single, R2C2 = 3',
    'Naked Single, R3C5 = 3',
    'Hidden Single, R7C6 = 3',
    'Hidden Single, R8C3 = 3',
    'Hidden Single, R8C8 = 6',
    'Naked Group, remove group 89 from R2C1 = 67',
    'Naked Group, remove group 89 from R2C3 = 67',
    'Naked Group, remove group 12 from R8C1 = 89',
    'Naked Group, remove group 12 from R9C3 = 67',
    'Region Combinations, K1 13:R1C3-4, R1C4 = 9',
    'Region Combinations, K2 14:R1C6-7, R1C6 = 8',
    'Region Combinations, K3 18:R2C3-4,R3C4, R2C3 = 7',
    'Region Combinations, K7 9:R3C5-6,R4C5, R4C5 = 2',
    'Region Combinations, K14 18:R6-8C5, R8C5 = 8',
    'Region Combinations, K17 8:R7-8C4,R8C3, R8C4 = 1',
    'Region Combinations, KV2 38iR2:R2C1-4,R2C8-9, R2C1 = 6',
    'Region Combinations, KV5 39iR3-4d:R3C3-4,R3C7,R4C3-4,R4C6, R3C3 = 8',
    'Region Combinations, KV6 22iC1:R1-2C1,R5C1,R8-9C1, R8C1 = 9',
    'Region Combinations, KV8 27iC5:R1-5C5,R9C5, R2C5 = 1',
    'Region Combinations, KV8 27iC5:R1-5C5,R9C5, R9C5 = 9',
    'Region Combinations, X1, R7C7 = 9',
    'Naked Single, R1C4 = 9',
    'Naked Single, R1C6 = 8',
    'Naked Single, R2C1 = 6',
    'Naked Single, R2C3 = 7',
    'Naked Single, R2C5 = 1',
    'Hidden Single, R2C6 = 2',
    'Hidden Single, R3C2 = 9',
    'Naked Single, R3C3 = 8',
    'Hidden Single, R4C2 = 8',
    'Naked Single, R4C5 = 2',
    'Hidden Single, R4C7 = 1',
    'Hidden Single, R4C9 = 9',
    'Hidden Single, R5C6 = 9',
    'Hidden Single, R5C7 = 8',
    'Hidden Single, R6C1 = 7',
    'Hidden Single, R6C2 = 6',
    'Hidden Single, R6C3 = 9',
    'Hidden Single, R6C4 = 8',
    'Hidden Single, R6C6 = 1',
    'Hidden Single, R6C7 = 2',
    'Hidden Single, R7C1 = 8',
    'Naked Single, R7C7 = 9',
    'Naked Single, R8C1 = 9',
    'Naked Single, R8C4 = 1',
    'Naked Single, R8C5 = 8',
    'Hidden Single, R8C9 = 2',
    'Hidden Single, R9C2 = 7',
    'Hidden Single, R9C3 = 6',
    'Hidden Single, R9C4 = 2',
    'Naked Single, R9C5 = 9',
    'Hidden Single, R9C8 = 8',
    'Naked Single, R1C1 = 2',
    'Hidden Single, R1C2 = 1',
    'Naked Single, R2C8 = 9',
    'Naked Single, R2C9 = 8',
    'Hidden Single, R3C8 = 2',
    'Naked Single, R3C9 = 1',
    'Hidden Single, R5C2 = 2',
    'Hidden Single, R5C3 = 1',
    'Hidden Single, R7C3 = 2',
    'Naked Single, R7C8 = 1',
    'Naked Single, R9C1 = 1',
    'Solved!',
    'Solution iterations=42',
    'SudokuX',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m13\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m14\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m18\x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[45m 7\x1B[49m\x1B[39m\x1B[30m\x1B[45m  \x1B[49m\x1B[39m\x1B[30m\x1B[45m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[42m 8\x1B[49m\x1B[39m\x1B[30m\x1B[43m17\x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 9\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 7\x1B[49m\x1B[39m\x1B[30m\x1B[43m10\x1B[49m\x1B[39m',
    '\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m11\x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m24\x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[42m15\x1B[49m\x1B[39m\x1B[30m\x1B[43m20\x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m18\x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 6\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m12\x1B[49m\x1B[39m',
    '\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m 8\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m15\x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[43m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 8\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[42m 8\x1B[49m\x1B[39m\x1B[30m\x1B[42m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m\x1B[30m\x1B[100m  \x1B[49m\x1B[39m',
    '214978653',
    '637512498',
    '598634721',
    '385726149',
    '421359876',
    '769841235',
    '852463917',
    '943187562',
    '176295384',
  ];

  group('API', () {
    test('killer1', () {
      var puzzle = SudokuAPI.killer(emptySudoku, killerPuzzle1, true);
      puzzle.addSudokuX();
      expect(
        puzzle.solve(true, false),
        killerSolution1.join('\n'),
      );
    });
  });
}
