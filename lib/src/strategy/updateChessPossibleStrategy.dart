import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/domino.dart';
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

    var updated = false;
    sudoku.grid.forEach((r) => r.forEach((c) {
          if (updateCell(c)) updated = true;
        }));
    return updated;
  }

  /// Update [cell] possible values according to neighbours
  bool updateCell(Cell cell) {
    var updated = false;

    if (cell.value != null) return false;

    // Look at neighbours of cell that are chess move away
    var chess = puzzle as Chess;
    if (chess.kingsMove) {
      var kingCells = sudoku.adjacentCells(cell);
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
}
