import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// If a number occurs twice or three times in just one unit (Row, Column or Box)
/// then we can remove that number from the intersection of another unit.
/// There are four types of intersection:
/// 1. In a box - if aligned on a row, n can be removed from the rest of the row.
/// 2. In a box - if aligned on a column, n can be removed from the rest of the column.
/// 3. On a row - if all in the same box, n can be removed from the rest of the box.
/// 4. On a column - if all in the same box, n can be removed from the rest of the box.
///
/// The first two types are called Pointing Pairs/Triples, the second two types are
/// called Line Box Reduction
///
/// In addition, if the group is contained in any other Region with unique values, then
/// n can be removed from the region.
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

  bool allBoxReduction(String scope) {
    var updated = false;
    for (var box = 1; box < 10; box++) {
      if (lineBoxReduction(scope, box)) updated = true;
    }
    return updated;
  }

  /// *lineBoxReduction* implement Pointing Group and Line Box Reduction
  ///
  /// Pointing Group - if scope is "B" then find unique value in Rows/Columns of
  /// Box and remove from rest of Row/Column
  /// Line Box Reduction - If scope is not "B" then find unique value in Rows/Columns
  /// contained in Box and remove from rest of Box
  bool lineBoxReduction(String scope, int box) {
    var updated = false;
    var cells = sudoku.getBox(box);
    // Check each Row then each Column of Box
    for (var axis in ['R', 'C']) {
      for (var boxMajor = 0; boxMajor < 3; boxMajor++) {
        // Three cells in Row/Column
        var cells3 = sudoku.getCells3(axis, boxMajor, cells);
        if (cells3.isEmpty) continue; // All set
        // Other six cells in Box
        var boxCells6 = cells
            .where((cell) => !cell.isSet && !cells3.contains(cell))
            .toList();
        // Other six cells in Row/Column
        var axisCells6 = sudoku.getCellAxis(axis, cells3[0]);
        axisCells6.removeWhere((cell) => cell.isSet || cells3.contains(cell));
        var locationAxis = addExplanation(
            explanation, '${cells3[0].boxName},${cells3[0].getAxisName(axis)}');
        // Get cells to check and cells to update according to scope
        late Cells cells6;
        late Cells updateCells;
        if (scope == 'B') {
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
          // The unique3 possible values can be removed from the Box or Row/Column
          for (var cell in updateCells) {
            if (cell.removePossible(unique3)) {
              updated = true;
              sudoku.cellUpdated(
                  cell, locationAxis, "remove group $unique3 from $cell");
            }
          }
          // They can be removed from any overlapping unique regions
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
                region.cells.forEach((cell) {
                  if (!uniqueCells.contains(cell)) {
                    // Remove value from other cells
                    if (cell.clearPossible(value)) {
                      updated = true;
                      sudoku.cellUpdated(cell, locationAxis,
                          "remove value $value from ${region.name} $cell");
                    }
                  } else {
                    // Value is mandatory in region for unique cells
                    if (!region.mandatory.containsKey(value))
                      region.mandatory[value] = {};
                    region.mandatory[value]!.addAll(uniqueCells);
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
