import 'package:sudoku/src/cell.dart';

abstract class Region<Puzzle> {
  Puzzle puzzle;
  List<Cell> cells;
  String name;
  bool nodups;
  Region(Puzzle this.puzzle, String this.name, bool this.nodups,
      List<Cell> this.cells);
  String toString();
}
