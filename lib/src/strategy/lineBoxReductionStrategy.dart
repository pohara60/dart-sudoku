import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';

bool pointingGroupStrategy(Grid grid) {
  var explanation = 'Pointing Group';
  return allBoxReduction(grid, 'box', explanation);
}

bool lineBoxReductionStrategy(Grid grid) {
  var explanation = 'Line Box Reduction';
  return allBoxReduction(grid, 'axis', explanation);
}

bool allBoxReduction(Grid grid, String target, String explanation) {
  var updated = false;
  for (var box = 1; box < 10; box++) {
    if (lineBoxReduction(grid, target, box, explanation)) updated = true;
  }
  return updated;
}

/// *lineBoxReduction* implement Point Group and Line Box Reduction
///
/// If target is "box" then find unique value in Rows/Columns of Box
/// and remove from rest of Box
/// If target is not "box" then find unique value in Rows/Columns in Box
/// and remove from rest of Row/Column
bool lineBoxReduction(Grid grid, String target, int box, String explanation) {
  var updated = false;
  var cells = grid.getBox(box);
  var location = addExplanation(explanation, cells[0].location("box"));
  // Check each Row then each Column of Box
  for (var axis in ['row', 'column']) {
    for (var boxMajor = 0; boxMajor < 3; boxMajor++) {
      // Three cells in Row/Column
      var cells3 = grid.getCells3(axis, boxMajor, cells);
      if (cells3.isEmpty) continue;
      // Other six cells in Box
      var boxCells6 =
          cells.where((cell) => !cell.isSet && !cells3.contains(cell)).toList();
      // Other six cells in Row/Column
      late List<Cell> axisCells6;
      late String locationAxis;
      if (axis == 'row') {
        axisCells6 = grid.getRow(cells3[0].row);
        locationAxis = addExplanation(location, '$axis[${cells3[0].row}]');
      } else {
        axisCells6 = grid.getColumn(cells3[0].col);
        locationAxis = addExplanation(location, '$axis[${cells3[0].col}]');
      }
      axisCells6.removeWhere((cell) => cell.isSet || cells3.contains(cell));
      // Get cells to check and cells to update according to target
      late List<Cell> cells6;
      late List<Cell> updateCells;
      if (target == 'box') {
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
