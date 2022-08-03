import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';

bool hiddenSingleStrategy(Grid grid) {
  var explanation = 'Hidden Single';
  var updated = false;
  grid.grid.forEach((r) => r.forEach((c) {
        if (cellHiddenSingle(grid, c, explanation)) updated = true;
      }));
  return updated;
}

/// Check [cell] for unique possible value
bool cellHiddenSingle(Grid grid, Cell cell, String explanation) {
  if (cell.value != null) return false;

  var updated = false;
  if (cell.checkUnique()) {
    updated = true;
  } else {
    // Check for a possible value not in box, row or column
    var cells = grid.getBoxForCell(cell.row, cell.col);
    cells.remove(cell);
    var otherPossible = unionCellsPossible(cells);
    var difference = cell.possible.subtract(otherPossible);
    var value = difference.unique();
    if (value > 0) {
      cell.value = value;
      updated = true;
    }
  }
  if (updated) {
    grid.cellUpdated(cell, explanation, '$cell');
  }
  return updated;
}
