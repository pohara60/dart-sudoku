import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// For every cell, check its Row/Column/Box for set values that can be removed
/// from the cell possibles
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
    for (var axis in ['B', 'R', 'C', 'X1', 'X2']) {
      var cells = sudoku
          .getCellAxis(axis, cell)
          .where((c) => c != cell && c.isSet)
          .toList();
      if (cells.length > 0) {
        var location = addExplanation(explanation, cells[0].getAxisName(axis));
        if (nonetUpdateCell(cell, cells, location)) updated = true;
      }
    }

    return updated;
  }

  /// Update [cell] possible values for values in box [cells], with label [explanation]
  bool nonetUpdateCell(Cell cell, Cells cells, String explanation) {
    var updated = false;
    var set = unionCellsPossible(cells);
    if (cell.removePossible(set)) {
      updated = true;
      sudoku.cellUpdated(cell, explanation, null);
      // Don't give messages about possible value updates
      // _messages.add(addExplanation(
      //     explanation, 'update possible cell ${cell.toString()}'));
    }

    return updated;
  }
}
