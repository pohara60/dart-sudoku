import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

import 'strategy/pointingDiagonalStrategy.dart';

class SudokuXRegion extends Region<Sudoku> {
  SudokuXRegion(Sudoku puzzle, String name, Cells cells)
      : super(puzzle, name, 45, true, cells);
  String toString() => '$name';
}

class SudokuX extends PuzzleDecorator {
  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Disgonals are Regions of type SudokuXRegion
  List<SudokuXRegion> get diagonals => List<SudokuXRegion>.from(
      this.regions.where((region) => region.runtimeType == SudokuXRegion));

  /// Get the puzzle Cage for a Cell
  List<SudokuXRegion> getDiagonals(Cell cell) => List<SudokuXRegion>.from(
      cell.regions.where((region) => region.runtimeType == SudokuXRegion));

  late RegionCombinationsStrategy regionCombinationsStrategy;
  late PointingDiagonalStrategy pointingDiagonalStrategy;

  void Function()? clearStateCallback = null;

  SudokuX.puzzle(Puzzle puzzle, {rising = true, falling = true}) {
    puzzle.clearStateCallback = clearState;
    this.puzzle = puzzle;
    var cells1 = <Cell>[];
    var cells2 = <Cell>[];
    for (var i = 0; i < 9; i++) {
      cells1.add(sudoku.grid[i][i]);
      cells2.add(sudoku.grid[i][8 - i]);
    }
    if (falling) allRegions['X1'] = SudokuXRegion(sudoku, 'X1', cells1);
    if (rising) allRegions['X2'] = SudokuXRegion(sudoku, 'X2', cells2);
    // Strategies
    regionCombinationsStrategy = RegionCombinationsStrategy(this);
    pointingDiagonalStrategy = PointingDiagonalStrategy(this);
  }

  String toString() {
    var text = 'SudokuX';
    text = '$text\n' + puzzle.toString();
    return text;
  }

  @override
  String solve(
      {bool explain = false,
      bool showPossible = false,
      List<Strategy>? easyStrategies,
      List<Strategy>? toughStrategies,
      Function? toStr}) {
    List<Strategy> strategies = Strategy.addStrategies(
      easyStrategies,
      [pointingDiagonalStrategy, regionCombinationsStrategy],
    );

    String stringFunc() => toStr == null ? toString() : toStr();

    return puzzle.solve(
        explain: explain,
        showPossible: showPossible,
        easyStrategies: strategies,
        toStr: stringFunc);
  }
}
