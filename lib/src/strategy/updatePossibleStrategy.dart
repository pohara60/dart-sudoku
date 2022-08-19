import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class UpdatePossibleStrategy extends Strategy {
  UpdatePossibleStrategy(sudoku) : super(sudoku, 'Update Possible');

  bool solve() {
    var updated = false;
    sudoku.grid.forEach((r) => r.forEach((c) {
          if (allNonetsUpdateCell(c)) updated = true;
        }));
    return updated;
  }

  /// Update [cell] possible values using its box, row and column
  bool allNonetsUpdateCell(Cell cell) {
    var updated = false;

    if (cell.value != null) return false;

    // Remove known values from box, row, col
    for (var axis in ['B', 'R', 'C']) {
      var cells = sudoku.getCellAxis(axis, cell);
      var location = addExplanation(explanation, cells[0].getAxisName(axis));
      if (nonetUpdateCell(cell, cells, location)) updated = true;
    }

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
            sudoku.cellError(c, explanation, 'duplicate value $value');
          } else {
            values[value - 1] = true;
          }
        }
      }
    }
    if (updated) {
      sudoku.cellUpdated(cell, explanation, null);
      // Don't give messages about possible value updates
      // _messages.add(addExplanation(
      //     explanation, 'update possible cell ${cell.toString()}'));
    }
    return updated;
  }
}
