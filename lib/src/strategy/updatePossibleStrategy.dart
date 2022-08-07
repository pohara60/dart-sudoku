import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class UpdatePossibleStrategy extends Strategy {
  UpdatePossibleStrategy(grid) : super(grid, 'Update Possible');

  bool solve() {
    var updated = false;
    grid.grid.forEach((r) => r.forEach((c) {
          if (allNonetsUpdateCell(c)) updated = true;
        }));
    return updated;
  }

  /// Update [cell] possible values using its box, row and column
  bool allNonetsUpdateCell(Cell cell) {
    var updated = false;

    if (cell.value != null) return false;

    // Remove known values from box, row, col
    var cells = grid.getBox(cell.box);
    var location = addExplanation(explanation, cells[0].location("box"));
    if (nonetUpdateCell(cell, cells, location)) updated = true;

    cells = grid.getRow(cell.row);
    location = addExplanation(explanation, cells[0].location("row"));
    if (nonetUpdateCell(cell, cells, location)) updated = true;

    cells = grid.getColumn(cell.col);
    location = addExplanation(explanation, cells[0].location("column"));
    if (nonetUpdateCell(cell, cells, location)) updated = true;

    return updated;
  }

  /// Update [cell] possible values for values in box [cells], with label [explanation]
  bool nonetUpdateCell(Cell cell, List<Cell> cells, String explanation) {
    var updated = false;
    var values = List<bool>.filled(9, false);
    for (final c in cells) {
      if (c != cell) {
        var value = c.value;
        if (value != null) {
          if (cell.remove(value)) {
            updated = true;
          }
          if (values[value - 1]) {
            grid.cellError(c, explanation, 'duplicate value $value');
          } else {
            values[value - 1] = true;
          }
        }
      }
    }
    if (updated) {
      grid.cellUpdated(cell, explanation, null);
      // Don't give messages about possible value updates
      // _messages.add(addExplanation(
      //     explanation, 'update possible cell ${cell.toString()}'));
    }
    return updated;
  }
}
