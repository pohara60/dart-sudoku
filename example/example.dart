import 'package:sudoku/sudoku.dart';

void main() {
  final sudoku = Sudoku();
  var str = sudoku.getSudoku();
  str = sudoku.getSudoku();
  print('getSudoku\n$str');

  sudoku.invokeAllStrategies(true);
}
