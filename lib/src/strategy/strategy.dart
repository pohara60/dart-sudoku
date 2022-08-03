import 'package:sudoku/src/grid.dart';

abstract class Strategy {
  final Grid grid;
  final String explanation;
  Strategy(this.grid, this.explanation);

  bool solve();
}
