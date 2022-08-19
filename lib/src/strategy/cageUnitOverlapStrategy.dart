import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/*
Type 1

Each 'cage' is made up of one or more 'combinations' - sets of numbers that total the cage clue. If you can find a candidate number inside that cage that is not found elsewhere on the row, columns or box the cage is aligned on, then you know that number must appear in the cage. That part is self-evident since, in the solver at least, these numbers are displayed. Given that number is true, we can remove all combinations which omit that number. Often that means we can remove a bunch of numbers.


Type 2
If Type 1 above is related to Box Line Reduction, then you'd recognize that Type 2 will look like Pointing Pairs, it's opposite. 

If can find a requied number in a cage that is aligned on a unit, then can remove the number
from the unit.


Bi-Value attack on a cage

If the cage is aligned with a unit, and a combination breaks another cell in the unit, then the
combination is not valid.

*/

class CageUnitOverlapStrategy extends Strategy {
  CageUnitOverlapStrategy(grid, [explanation = 'Cage Unit Overlap'])
      : super(grid, explanation);

  bool solve() {
    return allBoxReduction('axis');
  }

  bool allBoxReduction(String target) {
    var updated = false;
    for (var box = 1; box < 10; box++) {
      if (cageUnitOverlap(target, box)) updated = true;
    }
    return updated;
  }

  /// *lineBoxReduction* implement Point Group and Line Box Reduction
  ///
  /// If target is "B" then find unique value in Rows/Columns of Box
  /// and remove from rest of Box
  /// If target is not "B" then find unique value in Rows/Columns in Box
  /// and remove from rest of Row/Column
  bool cageUnitOverlap(String target, int box) {
    var updated = false;
    var cells = grid.getBox(box);
    var location = addExplanation(explanation, cells[0].getAxisName('B'));
    // Check each Row then each Column of Box
    for (var axis in ['R', 'C']) {
      for (var boxMajor = 0; boxMajor < 3; boxMajor++) {
        // Three cells in Row/Column
        var cells3 = grid.getCells3(axis, boxMajor, cells);
        if (cells3.isEmpty) continue;
        // Other six cells in Box
        var boxCells6 = cells
            .where((cell) => !cell.isSet && !cells3.contains(cell))
            .toList();
        // Other six cells in Row/Column
        late List<Cell> axisCells6;
        late String locationAxis;
        axisCells6 = grid.getCellAxis(axis, cells3[0]);
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
              grid.cellUpdated(
                  cell, locationAxis, "remove group $unique3 from $cell");
            }
          }
        }
      }
    }
    return updated;
  }
}
