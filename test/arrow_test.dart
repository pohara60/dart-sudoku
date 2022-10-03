import 'package:sudoku/sudokuAPI.dart';
import 'package:test/test.dart';

void main() {
  var sudokuPuzzle1 = [
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
  var arrowSolution1 = [
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m↑\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m|\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m→\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m→\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m→\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m←\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m|\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m←\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m|\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m←\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m↓\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '8..3.....',
    '.........',
    '.........',
    '........6',
    '.........',
    '5........',
    '.........',
    '.........',
    '.....7..1',
    'Region Combinations, A1:R3C2-5, R3C2 = 679',
    'Region Combinations, A1:R3C2-5, R3C3 = 12346',
    'Region Combinations, A1:R3C2-5, R3C4 = 12456',
    'Region Combinations, A1:R3C2-5, R3C5 = 12456',
    'Region Combinations, A2:R3-1C7, R3C7 = 3456789',
    'Region Combinations, A2:R3-1C7, R2C7 = 12345678',
    'Region Combinations, A2:R3-1C7, R1C7 = 124567',
    'Region Combinations, A3:R4C3-6, R4C3 = 789',
    'Region Combinations, A3:R4C3-6, R4C4 = 1245',
    'Region Combinations, A3:R4C3-6, R4C5 = 12345',
    'Region Combinations, A3:R4C3-6, R4C6 = 12345',
    'Region Combinations, A4:R5C4-7, R5C4 = 6789',
    'Region Combinations, A4:R5C4-7, R5C5 = 123456',
    'Region Combinations, A4:R5C4-7, R5C6 = 123456',
    'Region Combinations, A4:R5C4-7, R5C7 = 12345',
    'Region Combinations, A5:R6-9C2, R6C2 = 6789',
    'Region Combinations, A5:R6-9C2, R7C2 = 123456',
    'Region Combinations, A5:R6-9C2, R8C2 = 123456',
    'Region Combinations, A5:R6-9C2, R9C2 = 23456',
    'Region Combinations, A6:R6C9-6, R6C9 = 789',
    'Region Combinations, A6:R6C9-6, R6C8 = 1234',
    'Region Combinations, A6:R6C9-6, R6C7 = 1234',
    'Region Combinations, A6:R6C9-6, R6C6 = 12346',
    'Region Combinations, A7:R7C8-5, R7C8 = 6789',
    'Region Combinations, A7:R7C8-5, R7C7 = 23456',
    'Region Combinations, A7:R7C8-5, R7C6 = 123456',
    'Region Combinations, A7:R7C8-5, R7C5 = 123456',
    'Region Combinations, A8:R8C7-4, R8C7 = 6789',
    'Region Combinations, A8:R8C7-4, R8C6 = 123456',
    'Region Combinations, A8:R8C7-4, R8C5 = 123456',
    'Region Combinations, A8:R8C7-4, R8C4 = 12456',
    'Hidden Group, set R5C4 = 789',
    'Hidden Group, set R6C4 = 789',
    'Hidden Group, set R6C5 = 789',
    'Naked Group, remove group 789 from R6C2 = 6',
    'Naked Group, remove group 789 from R6C3 = 12346',
    'Hidden Single, R6C2 = 6',
    'Pointing Group, B7,C3, remove group 8 from R4C3 = 79',
    'Pointing Group, B7,C3, remove group 8 from R5C3 = 123479',
    'Line Box Reduction, B2,C6, remove group 89 from R1C5 = 124567',
    'Line Box Reduction, B2,C6, remove group 89 from R2C4 = 124567',
    'Line Box Reduction, B2,C6, remove group 89 from R2C5 = 124567',
    'Hidden Group, set R6C5 = 89',
    'Hidden Group, set R9C5 = 89',
    'Pointing Group, B5,C4, remove group 7 from R2C4 = 12456',
    'Region Combinations, A4:R5C4-7, R5C4 = 9',
    'Region Combinations, A4:R5C4-7, R5C5 = 126',
    'Region Combinations, A4:R5C4-7, R5C6 = 126',
    'Region Combinations, A4:R5C4-7, R5C7 = 12',
    'Region Combinations, A5:R6-9C2, R7C2 = 123',
    'Region Combinations, A5:R6-9C2, R8C2 = 123',
    'Region Combinations, A5:R6-9C2, R9C2 = 23',
    'Hidden Single, R5C4 = 9',
    'Hidden Single, R6C4 = 7',
    'Hidden Single, R6C5 = 8',
    'Hidden Single, R6C9 = 9',
    'Hidden Single, R9C5 = 9',
    'Naked Group, remove group 123 from R7C1 = 4679',
    'Naked Group, remove group 123 from R7C3 = 456789',
    'Naked Group, remove group 123 from R8C1 = 4679',
    'Naked Group, remove group 123 from R8C3 = 456789',
    'Naked Group, remove group 123 from R9C1 = 46',
    'Naked Group, remove group 123 from R9C3 = 4568',
    'Naked Group, remove group 126 from R5C1 = 347',
    'Naked Group, remove group 126 from R5C2 = 3478',
    'Naked Group, remove group 126 from R5C3 = 347',
    'Naked Group, remove group 126 from R5C8 = 34578',
    'Naked Group, remove group 126 from R5C9 = 34578',
    'Naked Group, remove group 123 from R1C2 = 4579',
    'Naked Group, remove group 123 from R2C2 = 4579',
    'Naked Group, remove group 123 from R4C2 = 4789',
    'Naked Group, remove group 123 from R5C2 = 478',
    'Hidden Group, set R4C1 = 12',
    'Hidden Group, set R6C3 = 12',
    'Pointing Group, B4,R5, remove group 3 from R5C8 = 4578',
    'Pointing Group, B4,R5, remove group 3 from R5C9 = 4578',
    'Pointing Group, B5,R4, remove group 5 from R4C7 = 123478',
    'Pointing Group, B5,R4, remove group 5 from R4C8 = 123478',
    'Pointing Group, B7,C3, remove group 58 from R1C3 = 124679',
    'Pointing Group, B7,C3, remove group 58 from R2C3 = 1234679',
    'Region Combinations, A3:R4C3-6, R4C3 = 9',
    'Region Combinations, A3:R4C3-6, R4C4 = 15',
    'Region Combinations, A3:R4C3-6, R4C5 = 135',
    'Region Combinations, A3:R4C3-6, R4C6 = 135',
    'Region Combinations, A6:R6C9-6, R6C8 = 234',
    'Region Combinations, A6:R6C9-6, R6C7 = 234',
    'Region Combinations, A6:R6C9-6, R6C6 = 234',
    'Hidden Single, R4C3 = 9',
    'Hidden Single, R6C3 = 1',
    'Hidden Single, R6C6 = 4',
    'Hidden Single, R4C1 = 2',
    'Naked Group, remove group 135 from R5C5 = 26',
    'Naked Group, remove group 135 from R5C6 = 26',
    'Naked Group, remove group 23 from R4C7 = 1478',
    'Naked Group, remove group 23 from R4C8 = 1478',
    'Naked Group, remove group 23 from R5C7 = 1',
    'Naked Group, remove group 123 from R4C7 = 478',
    'Naked Group, remove group 123 from R4C8 = 478',
    'Hidden Single, R5C7 = 1',
    'Pointing Group, B7,C1, remove group 9 from R2C1 = 13467',
    'Pointing Group, B7,C1, remove group 9 from R3C1 = 13467',
    'Region Combinations, A2:R3-1C7, R3C7 = 56789',
    'Region Combinations, A2:R3-1C7, R2C7 = 234567',
    'Region Group Combinations, AG1 R7,(A5, A7):R7C2,R7C5-7,R8-9C2, R7C8 = 789',
    'Region Group Combinations, AG2 R8,(A5, A8):R7-8C2,R8C4-6,R9C2, R8C7 = 789',
    'Region Group Combinations, AG4 C5,(A1, A3, A4, A7, A8):R3C3-5,R4C4-6,R5C5-7,R7C5-7,R8C4-6, R7C7 = 2345',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R7C8 = 89',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R8C7 = 89',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R6C7 = 3',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R6C8 = 2',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R7C5 = 1345',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R7C6 = 135',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R7C7 = 2',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R8C4 = 1245',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R8C5 = 12345',
    'Region Group Combinations, AG5 C6,(A3, A4, A6, A7, A8):R4C4-6,R5C5-7,R6C6-8,R7C5-7,R8C4-6, R8C6 = 1235',
    'Region Group Combinations, AG6 C7,(A2, A4, A6, A7):R1-2C7,R5C5-7,R6C6-8,R7C5-7, R3C7 = 6789',
    'Region Group Combinations, AG6 C7,(A2, A4, A6, A7):R1-2C7,R5C5-7,R6C6-8,R7C5-7, R1C7 = 4567',
    'Region Group Combinations, AG6 C7,(A2, A4, A6, A7):R1-2C7,R5C5-7,R6C6-8,R7C5-7, R2C7 = 4567',
    'Hidden Single, R6C7 = 3',
    'Hidden Single, R6C8 = 2',
    'Hidden Single, R7C7 = 2',
    'Naked Group, remove group 89 from R7C9 = 3457',
    'Naked Group, remove group 89 from R8C8 = 34567',
    'Naked Group, remove group 89 from R8C9 = 3457',
    'Naked Group, remove group 89 from R9C7 = 456',
    'Naked Group, remove group 89 from R9C8 = 3456',
    'Hidden Group, set R7C4 = 68',
    'Hidden Group, set R9C4 = 68',
    'Hidden Single, R9C2 = 2',
    'Hidden Single, R9C8 = 3',
    'Naked Group, remove group 68 from R2C4 = 1245',
    'Naked Group, remove group 68 from R3C4 = 1245',
    'Region Combinations, A2:R3-1C7, R3C7 = 9',
    'Region Combinations, A2:R3-1C7, R2C7 = 45',
    'Region Combinations, A2:R3-1C7, R1C7 = 45',
    'Region Combinations, A7:R7C8-5, R7C5 = 145',
    'Hidden Single, R3C7 = 9',
    'Hidden Single, R4C7 = 7',
    'Hidden Single, R8C7 = 8',
    'Hidden Single, R9C7 = 6',
    'Hidden Single, R3C2 = 7',
    'Hidden Single, R7C4 = 6',
    'Hidden Single, R7C8 = 9',
    'Hidden Single, R8C1 = 9',
    'Hidden Single, R8C3 = 6',
    'Hidden Single, R9C1 = 4',
    'Hidden Single, R9C3 = 5',
    'Hidden Single, R9C4 = 8',
    'Hidden Single, R7C1 = 7',
    'Hidden Single, R7C3 = 8',
    'Hidden Single, R5C1 = 3',
    'Hidden Single, R5C3 = 7',
    'Naked Group, remove group 234 from R1C2 = 59',
    'Naked Group, remove group 234 from R2C2 = 59',
    'Naked Group, remove group 45 from R1C8 = 167',
    'Naked Group, remove group 45 from R1C9 = 27',
    'Naked Group, remove group 45 from R2C8 = 1678',
    'Naked Group, remove group 45 from R2C9 = 2378',
    'Naked Group, remove group 45 from R3C8 = 168',
    'Naked Group, remove group 45 from R3C9 = 238',
    'Line Box Reduction, B2,R3, remove group 5 from R1C5 = 12467',
    'Line Box Reduction, B2,R3, remove group 5 from R1C6 = 1269',
    'Line Box Reduction, B2,R3, remove group 5 from R2C4 = 124',
    'Line Box Reduction, B2,R3, remove group 5 from R2C5 = 12467',
    'Line Box Reduction, B2,R3, remove group 5 from R2C6 = 12689',
    'Region Combinations, A1:R3C2-5, R3C3 = 24',
    'Region Combinations, A1:R3C2-5, R3C4 = 124',
    'Region Combinations, A1:R3C2-5, R3C5 = 124',
    'Region Combinations, A7:R7C8-5, R7C6 = 3',
    'Region Combinations, A7:R7C8-5, R7C5 = 4',
    'Region Combinations, A8:R8C7-4, R8C6 = 125',
    'Region Combinations, A8:R8C7-4, R8C5 = 125',
    'Region Combinations, A8:R8C7-4, R8C4 = 125',
    'Hidden Single, R2C3 = 3',
    'Hidden Single, R3C6 = 5',
    'Hidden Single, R3C9 = 3',
    'Hidden Single, R4C5 = 3',
    'Hidden Single, R7C2 = 1',
    'Hidden Single, R7C5 = 4',
    'Hidden Single, R7C6 = 3',
    'Hidden Single, R7C9 = 5',
    'Hidden Single, R8C2 = 3',
    'Hidden Single, R8C5 = 5',
    'Hidden Single, R2C6 = 8',
    'Hidden Single, R3C8 = 8',
    'Hidden Single, R4C4 = 5',
    'Hidden Single, R4C6 = 1',
    'Hidden Single, R5C8 = 5',
    'Hidden Single, R1C6 = 9',
    'Hidden Single, R2C2 = 9',
    'Hidden Single, R2C7 = 5',
    'Hidden Single, R3C1 = 6',
    'Hidden Single, R4C2 = 8',
    'Hidden Single, R4C8 = 4',
    'Hidden Single, R5C2 = 4',
    'Hidden Single, R5C6 = 6',
    'Hidden Single, R5C9 = 8',
    'Hidden Single, R8C4 = 1',
    'Hidden Single, R8C6 = 2',
    'Hidden Single, R8C9 = 4',
    'Hidden Single, R1C2 = 5',
    'Hidden Single, R1C7 = 4',
    'Hidden Single, R2C1 = 1',
    'Hidden Single, R2C4 = 4',
    'Hidden Single, R3C4 = 2',
    'Hidden Single, R3C5 = 1',
    'Hidden Single, R5C5 = 2',
    'Hidden Single, R8C8 = 7',
    'Hidden Single, R1C3 = 2',
    'Hidden Single, R1C8 = 1',
    'Hidden Single, R2C8 = 6',
    'Hidden Single, R2C9 = 2',
    'Hidden Single, R3C3 = 4',
    'Hidden Single, R1C5 = 6',
    'Hidden Single, R1C9 = 7',
    'Hidden Single, R2C5 = 7',
    'Solved!',
    'Solution iterations=57',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m↑\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m|\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m→\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m→\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m→\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m←\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m|\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m←\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m|\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m←\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m-\x1B[49m\x1B[39m\x1B[30m\x1B[100m○\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[100m↓\x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m\x1B[30m\x1B[47m \x1B[49m\x1B[39m',
    '852369417',
    '193478562',
    '674215983',
    '289531746',
    '347926158',
    '561784329',
    '718643295',
    '936152874',
    '425897631',
  ];

  group('API', () {
    test('arrow1', () {
      var puzzle = SudokuAPI.sudoku(sudokuPuzzle1);
      puzzle.addArrow(arrowPuzzle1);
      expect(
        puzzle.solve(true, false),
        arrowSolution1.join('\n'),
      );
    });
  });
}
