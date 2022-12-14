import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// B.U.G. = Bi-value Universal Graveyard
/// Any Sudoku where all remaining cells contain just two candidates is fatally flawed.
/// There must be a last remaining cell with three candidates. The odd number that can't
/// be paired with another cell has to be the solution for that cell to prevent BUG.
class BugStrategy extends Strategy {
  BugStrategy(grid) : super(grid, 'BUG');

  bool solve() {
    var updated = false;
    // Check for BUG candidate in rows, columns and boxes
    Cell? bugCell;
    var bugOK = true;
    var bugValue = 0;
    for (var axis in ['R', 'C', 'B']) {
      for (var major = 1; major < 10; major++) {
        var cells = sudoku
            .getMajorAxis(axis, major)
            .where((cell) => !cell.isSet)
            .toList();
        var countCellsPossibles = countCellsPossible(cells);
        var countCellsPossible3plus =
            countCellsPossibles.where((count) => count > 2).length;
        var valueCellsPossible3 =
            countCellsPossibles.indexWhere((count) => count == 3) + 1;
        var countValuesPossibles =
            cells.map((cell) => cell.possibleCount).toList();
        var countValuesPossible3plus =
            countValuesPossibles.where((count) => count > 2).length;
        var cellValuesPossible3 =
            countValuesPossibles.indexWhere((count) => count == 3);
        if (countCellsPossible3plus == 1 &&
            valueCellsPossible3 > 0 &&
            countValuesPossible3plus == 1 &&
            cellValuesPossible3 >= 0) {
          // Candidate bug cell
          //print('BUG: $valueCellsPossible3 in ${cells[cellValuesPossible3]}');
          if (bugCell == null) {
            bugCell = cells[cellValuesPossible3];
            bugValue = valueCellsPossible3;
          } else if (bugCell == cells[cellValuesPossible3]) {
            // Still OK
          } else {
            bugOK = false;
          }
        } else if (countCellsPossible3plus == 0 &&
            countValuesPossible3plus == 0) {
          // Still OK
        } else {
          bugOK = false;
        }
      }
    }
    if (bugOK && bugCell != null) {
      bugCell.value = bugValue;
      updated = true;
      sudoku.cellUpdated(bugCell, explanation, "$bugCell");
    }
    return updated;
  }
}
