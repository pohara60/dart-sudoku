import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/strategy/strategy.dart';

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
    var chess = puzzle as Chess;

    var updated = false;

    // Update possible for set cells
    sudoku.grid.forEach((r) => r.forEach((c) {
          if (updateCell(c)) updated = true;
        }));

    // Find adjacent pairs and update adjacent cells
    if (chess.kingsMove && updateKingsPairs()) updated = true;

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

  // TODO similar logic for knightsMove
  bool updateKingsPairs() {
    bool updated = false;
    for (var axis in ['R', 'C', 'B']) {
      var valuePossibleTwiceMajors = sudoku.getValuePossibleIndexes(axis, 2);
      for (var value = 1; value < 10; value++) {
        var majors = valuePossibleTwiceMajors[value];
        if (majors != null) {
          majors.forEach((major1, minors) {
            assert(minors.length == 2);
            int adjacentAxis(major1) {
              var major2 = 0;
              if (major1 % 3 == 0) major2 = major1 + 1;
              if (major1 % 3 == 1) major2 = major1 - 1;
              return major2;
            }

            if (axis == 'B') {
              // Pair in box
              var cell1 = sudoku.getAxisCell(axis, major1, minors[0]);
              var cell2 = sudoku.getAxisCell(axis, major1, minors[1]);
              for (var axis2 in ['R', 'C']) {
                var cell1major2 = cell1.getAxis(axis2);
                var cell2major2 = cell2.getAxis(axis2);
                // Pair in same axis handled by other branch
                // Want adjacent axes
                if (cell1major2 == cell2major2 + 1 ||
                    cell1major2 + 1 == cell2major2) {
                  bool updateAdjacentAxis(Cell cell1, Cell cell2) {
                    var updated = false;
                    var minor1 = cell1.getMinorAxis(axis2);
                    var minor2 = adjacentAxis(minor1);
                    if (minor2 > 0 && minor2 < 10) {
                      // Clear value from adjacent minor axis in other cell major axis
                      var major2 = cell2.getAxis(axis2);
                      var cell = sudoku.getAxisCell(axis2, major2, minor2);
                      if (cell.clearPossible(value)) {
                        updated = true;
                        sudoku.cellUpdated(cell, explanation,
                            "remove offset value $value from $cell");
                      }
                    }
                    return updated;
                  }

                  // Update adjacent axis of each cell
                  if (updateAdjacentAxis(cell1, cell2)) updated = true;
                  if (updateAdjacentAxis(cell2, cell1)) updated = true;
                }
              }
            } else {
              // Pair in row/col
              var major2 = adjacentAxis(major1);
              // If adjacent pair next to different box
              if (minors[0] + 1 == minors[1] && major2 > 0 && major2 < 10) {
                // Remove value from adjacent axis cells
                minors.forEach((minor) {
                  var cell = sudoku.getAxisCell(axis, major2, minor);
                  if (cell.clearPossible(value)) {
                    updated = true;
                    sudoku.cellUpdated(cell, explanation,
                        "remove pair value $value from $cell");
                  }
                });
              }
            }
          });
        }
      }
    }
    return updated;
  }
}
