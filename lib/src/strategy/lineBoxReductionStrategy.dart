import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class PointingGroupStrategy extends LineBoxReductionStrategy {
  PointingGroupStrategy(sudoku) : super(sudoku, 'Pointing Group');

  bool solve() {
    return allBoxReduction('B');
  }
}

class LineBoxReductionStrategy extends Strategy {
  LineBoxReductionStrategy(sudoku, [explanation = 'Line Box Reduction'])
      : super(sudoku, explanation);

  bool solve() {
    return allBoxReduction('axis');
  }

  bool allBoxReduction(String target) {
    var updated = false;
    for (var box = 1; box < 10; box++) {
      if (lineBoxReduction(target, box)) updated = true;
    }
    return updated;
  }

  /// *lineBoxReduction* implement Point Group and Line Box Reduction
  ///
  /// If target is "B" then find unique value in Rows/Columns of Box
  /// and remove from rest of Box
  /// If target is not "B" then find unique value in Rows/Columns in Box
  /// and remove from rest of Row/Column
  bool lineBoxReduction(String target, int box) {
    var updated = false;
    var cells = sudoku.getBox(box);
    var location = addExplanation(explanation, cells[0].getAxisName('B'));
    // Check each Row then each Column of Box
    for (var axis in ['R', 'C']) {
      for (var boxMajor = 0; boxMajor < 3; boxMajor++) {
        // Three cells in Row/Column
        var cells3 = sudoku.getCells3(axis, boxMajor, cells);
        if (cells3.isEmpty) continue;
        // Other six cells in Box
        var boxCells6 = cells
            .where((cell) => !cell.isSet && !cells3.contains(cell))
            .toList();
        // Other six cells in Row/Column
        late List<Cell> axisCells6;
        late String locationAxis;
        axisCells6 = sudoku.getCellAxis(axis, cells3[0]);
        locationAxis =
            addExplanation(location, '${cells3[0].getAxisName(axis)}');
        axisCells6.removeWhere((cell) => cell.isSet || cells3.contains(cell));
        // Get cells to check and cells to update according to target
        late List<Cell> cells6;
        late List<Cell> updateCells;
        if (target == 'B') {
          cells6 = boxCells6;
          updateCells = axisCells6;
        } else {
          cells6 = axisCells6;
          updateCells = boxCells6;
        }
        // Get values in three cells that do not appear in the six cells
        var possible3 = unionCellsPossible(cells3);
        var possible6 = unionCellsPossible(cells6);
        var unique3 = possible3.subtract(possible6);
        if (unique3.count > 0) {
          // The unique3 possible values can be removed from the Box/Row/Column
          for (var cell in updateCells) {
            if (cell.removePossible(unique3)) {
              updated = true;
              sudoku.cellUpdated(
                  cell, locationAxis, "remove group $unique3 from $cell");
            }
          }
          // They can be removed from any overlapping unique killer regions
          for (var value = 1; value < 10; value++) {
            if (unique3[value]) {
              var uniqueCells = cells3.where((cell) => cell.possible[value]);
              var overlapRegions = uniqueCells
                  .expand((cell) => cell.regions)
                  .toSet()
                  .where((region) =>
                      region.nodups &&
                      region.cells.toSet().containsAll(uniqueCells))
                  .toSet();
              overlapRegions.forEach((region) {
                region.cells
                    .where((cell) => !uniqueCells.contains(cell))
                    .forEach((cell) {
                  if (cell.clearPossible(value)) {
                    updated = true;
                    sudoku.cellUpdated(
                        cell, locationAxis, "remove value $value from $cell");
                  }
                });
              });
            }
          }
        }
      }
    }
    return updated;
  }
}
