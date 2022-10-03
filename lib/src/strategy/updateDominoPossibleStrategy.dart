import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/domino.dart';
import 'package:sudoku/src/strategy/strategy.dart';

import '../puzzle.dart';

/// For every cell, check its Row/Column/Box for set values that can be removed
/// from the cell possibles
class UpdateDominoPossibleStrategy extends Strategy {
  UpdateDominoPossibleStrategy(Puzzle puzzle)
      : super(puzzle, 'Update Domino Possible');

  bool solve() {
    // Should only apply to Domino puzzles
    if (!(puzzle is Domino)) return false;

    var domino = puzzle as Domino;
    if (!domino.negative) return false;

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

    // Look at neighbours of cell that are not in domino with it
    var domino = puzzle as Domino;
    var otherCells = sudoku.adjacentCells(cell);
    for (var otherCell in otherCells) {
      if (domino.sharedDomino(cell, otherCell) == null) {
        if (cell.removePossible(domino.cellNeighbourImpossible(otherCell)))
          updated = true;
      }
    }

    if (updated) {
      sudoku.cellUpdated(cell, explanation, 'update cell $cell');
    }

    return updated;
  }
}
