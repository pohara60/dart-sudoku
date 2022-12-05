import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/strategy/strategy.dart';
import 'package:sudoku/src/sudoku.dart';

import '../chess.dart';
import '../puzzle.dart';

/// For every cell, check its Row/Column/Box for set values that can be removed
/// from the cell possibles
class UpdateChessPossibleStrategy extends Strategy {
  UpdateChessPossibleStrategy(Puzzle puzzle)
      : super(puzzle, 'Update Chess Possible');

  bool solve() {
    // Should only apply to Chess puzzles
    if (!(puzzle is Chess)) return false;

    var updated = false;

    // Update possible for set cells
    sudoku.grid.forEach((r) => r.forEach((c) {
          if (updateCell(c)) updated = true;
        }));

    // Find adjacent pairs and update adjacent cells
    if (updatePairs()) updated = true;

    return updated;
  }

  /// Update [cell] possible values according to neighbours
  bool updateCell(Cell cell) {
    var updated = false;

    if (cell.value != null) return false;

    // Look at neighbours of cell that are chess move away
    var chess = puzzle as Chess;
    if (chess.kingsMove) {
      var kingCells = sudoku.kingsMoveCells(cell);
      for (var otherCell in kingCells) {
        if (otherCell.isSet) {
          if (cell.remove(otherCell.value!)) updated = true;
        }
      }
    }
    if (chess.knightsMove) {
      var knightCells = sudoku.knightsMoveCells(cell);
      for (var otherCell in knightCells) {
        if (otherCell.isSet) {
          if (cell.remove(otherCell.value!)) updated = true;
        }
      }
    }

    if (updated) {
      sudoku.cellUpdated(cell, explanation, 'update cell $cell');
    }

    return updated;
  }

  bool updatePairs() {
    var chess = puzzle as Chess;

    bool updated = false;
    for (var axis in ['B', 'R', 'C']) {
      var valuePossibleTwiceMajors = sudoku.getValuePossibleIndexes(axis, 3);
      for (var value = 1; value < 10; value++) {
        var majors = valuePossibleTwiceMajors[value];
        if (majors != null) {
          majors.forEach((major1, minors) {
            // Process Kings and Knights moves
            const KINGS = 'Kings';
            const KNIGHTS = 'Knights';
            for (var move in [
              if (chess.kingsMove) KINGS,
              if (chess.knightsMove) KNIGHTS
            ]) {
              void updateCell(cell, value, annotation) {
                if (cell.clearPossible(value)) {
                  updated = true;
                  var location = addExplanation(explanation, '$axis$major1');
                  sudoku.cellUpdated(cell, location,
                      "remove $move $annotation value $value from $cell");
                }
              }

              var cell1 = sudoku.getAxisCell(axis, major1, minors[0]);
              var cell2 = sudoku.getAxisCell(axis, major1, minors[1]);
              if (minors.length == 2 && axis == 'B') {
                // Pair in box
                for (var axis2 in ['R', 'C']) {
                  var cell1major2 = cell1.getAxis(axis2);
                  var cell2major2 = cell2.getAxis(axis2);
                  // Pair in same axis handled by other branch
                  // Want adjacent axes
                  if (cell1major2 != cell2major2) {
                    bool updateAdjacentAxis(Cell cell1, Cell cell2) {
                      var updated = false;
                      var cells = move == KINGS
                          ? sudoku.kingsMoveCells(cell1)
                          : sudoku.knightsMoveCells(cell1);
                      for (var cell in cells) {
                        // Clear value from move cell in other cell major axis
                        if (cell != cell2 &&
                            cell.getAxis(axis2) == cell2.getAxis(axis2)) {
                          updateCell(cell, value, 'offset');
                        }
                      }
                      return updated;
                    }

                    // Update adjacent axis of each cell
                    if (updateAdjacentAxis(cell1, cell2)) updated = true;
                    if (updateAdjacentAxis(cell2, cell1)) updated = true;
                  }
                }
              }

              var cells = move == KNIGHTS
                  ? intersectionCells(sudoku.knightsMoveCells(cell1),
                      sudoku.knightsMoveCells(cell2))
                  : intersectionCells(sudoku.kingsMoveCells(cell1),
                      sudoku.kingsMoveCells(cell2));
              if (minors.length == 3) {
                var cell3 = sudoku.getAxisCell(axis, major1, minors[2]);
                cells = move == KNIGHTS
                    ? intersectionCells(cells, sudoku.knightsMoveCells(cell3))
                    : intersectionCells(cells, sudoku.kingsMoveCells(cell3));
              }
              for (var cell in cells) {
                // Clear value from intersection cells
                updateCell(cell, value, 'intersection');
              }
            }
          });
        }
      }
    }
    return updated;
  }
}
