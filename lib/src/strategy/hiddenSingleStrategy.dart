import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class HiddenSingleStrategy extends Strategy {
  HiddenSingleStrategy(grid) : super(grid, 'Hidden Single');

  bool solve() {
    var updated = false;
    grid.cellGrid.forEach((row) => row.forEach((cell) {
          if (cellHiddenSingle(cell)) updated = true;
        }));
    return updated;
  }

  /// Check [cell] for unique possible value
  bool cellHiddenSingle(Cell cell) {
    if (cell.isSet) return false;

    var updated = false;
    if (cell.checkUnique()) {
      updated = true;
    } else {
      // Check for a possible value not in box, row or column
      for (var axis in ['R', 'C', 'B']) {
        var cells = grid.getMajorAxis(axis, cell.getAxis(axis));
        cells.remove(cell);
        var otherPossible = unionCellsPossible(cells);
        var difference = cell.possible.subtract(otherPossible);
        var value = difference.unique();
        if (value > 0) {
          cell.value = value;
          updated = true;
        }
      }
    }
    if (updated) {
      grid.cellUpdated(cell, explanation, '$cell');
    }
    return updated;
  }
}
