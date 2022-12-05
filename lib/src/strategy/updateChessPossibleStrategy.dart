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
            var cell1 = sudoku.getAxisCell(axis, major1, minors[0]);
            var cell2 = sudoku.getAxisCell(axis, major1, minors[1]);

            var cells = intersectionCells(
                sudoku.coveredCells(
                  cell1,
                  excludeAxes: [axis],
                  kingsMove: chess.kingsMove,
                  knightsMove: chess.knightsMove,
                ),
                sudoku.coveredCells(
                  cell2,
                  excludeAxes: [axis],
                  kingsMove: chess.kingsMove,
                  knightsMove: chess.knightsMove,
                ));
            var names = '${cell1.name},${cell2.name}';
            if (minors.length == 3) {
              var cell3 = sudoku.getAxisCell(axis, major1, minors[2]);
              cells = intersectionCells(
                  cells,
                  sudoku.coveredCells(
                    cell3,
                    excludeAxes: [axis],
                    kingsMove: chess.kingsMove,
                    knightsMove: chess.knightsMove,
                  ));
              names += ',${cell3.name}';
            }
            for (var cell in cells) {
              // Clear value from intersection cells
              if (cell.clearPossible(value)) {
                updated = true;
                var location =
                    addExplanation(explanation, '$axis$major1($names)');
                sudoku.cellUpdated(
                    cell, location, "remove value $value from $cell");
              }
            }
          });
        }
      }
    }
    return updated;
  }
}
