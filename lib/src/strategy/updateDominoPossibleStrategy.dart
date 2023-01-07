import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/domino.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

import '../dominoRegion.dart';
import '../possible.dart';
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

    if (domino.negative) {
      if (updatePairsAndTriples(domino)) updated = true;
    }

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

  bool updatePairsAndTriples(Domino domino) {
    var updated = false;
    for (var axis in ['R', 'C', 'B']) {
      var valuePossibleMajors = sudoku.getValuePossibleIndexes(axis, 3);
      for (var value = 1; value < 10; value++) {
        // Get negative values
        var negativeValues = Possible(false);
        if (domino.dominoTypes.contains(DominoType.DOMINO_C)) {
          if (value > 1) negativeValues[value - 1] = true;
          if (value < 9) negativeValues[value + 1] = true;
        }
        if (domino.dominoTypes.contains(DominoType.DOMINO_M)) {
          if (value < 5) negativeValues[value * 2] = true;
          if (value % 2 == 0) negativeValues[value ~/ 2] = true;
        }
        if (domino.dominoTypes.contains(DominoType.DOMINO_V)) {
          if (value < 5) negativeValues[5 - value] = true;
        }
        if (domino.dominoTypes.contains(DominoType.DOMINO_X)) {
          if (value != 5) negativeValues[10 - value] = true;
        }
        var majors = valuePossibleMajors[value];
        if (majors != null && negativeValues.count > 0) {
          majors.forEach((major, minors) {
            // Are the minors adjacent?
            var orthCentre = getAxisOrthogonal(axis, minors);
            var proceed = true;
            if (orthCentre == -1) {
              proceed = false;
            } else {
              // If domino then skip
              for (var pair in [
                [0, 1],
                if (minors.length == 3) [0, 2],
                if (minors.length == 3) [1, 2],
              ]) {
                var dom = domino.sharedDomino(
                    sudoku.getAxisCell(axis, major, minors[pair[0]]),
                    sudoku.getAxisCell(axis, major, minors[pair[1]]));
                if (dom != null && domino.dominoTypes.contains(dom.type)) {
                  proceed = false;
                  break;
                }
              }
            }
            if (proceed) {
              var location = addExplanation(explanation,
                  '${axis}$major:${minors[0]},${minors[1]}${minors.length == 3 ? ",${minors[2]}" : ""}');
              for (var cell in [
                if (minors.length == 2)
                  sudoku.getAxisCell(axis, major, minors[0]),
                if (minors.length == 2)
                  sudoku.getAxisCell(axis, major, minors[1]),
                if (minors.length == 3)
                  sudoku.getAxisCell(axis, major, minors[orthCentre - 1]),
              ]) {
                // Remove the negative values from the cell
                if (cell.removePossible(negativeValues)) {
                  updated = true;
                  sudoku.cellUpdated(
                      cell, location, "remove $negativeValues from $cell");
                }

                // For 3 cells, if the 2 non-centre cells minus the value are
                // a pair that includes a negative value, then the value can be
                // removed from the centre cell
                if (minors.length == 3) {
                  var otherCells = sudoku
                      .getMajorAxis(axis, major)
                      .whereIndexed((index, element) =>
                          minors.contains(index + 1) &&
                          index + 1 != minors[orthCentre - 1])
                      .toList();
                  var possible = unionCellsPossible(otherCells);
                  if (possible.count == 3 &&
                      possible.intersect(negativeValues).count > 0 &&
                      cell.remove(value)) {
                    updated = true;
                    sudoku.cellUpdated(
                        cell, location, "remove $value from centre $cell");
                  }
                }
              }
            }
          });
        }
      }
    }
    return updated;
  }

  int getAxisOrthogonal(String axis, List<int> minors) {
    if (['R', 'C'].contains(axis) &&
        minors.length == minors.last - minors.first + 1) return 2;
    if (axis == 'B') {
      var orth12 = isBoxOrthogonal(minors[0], minors[1]);
      if (minors.length == 2) return orth12 ? 0 : -1;
      var orth13 = isBoxOrthogonal(minors[0], minors[2]);
      var orth23 = isBoxOrthogonal(minors[1], minors[2]);
      if (orth12 && orth23) return 2;
      if (orth12 && orth13) return 1;
      if (orth23 && orth13) return 3;
    }
    return -1;
  }

  bool isBoxOrthogonal(int i1, int i2) {
    var index1 = i1 < i2 ? i1 : i2;
    var index2 = i1 < i2 ? i2 : i1;
    if (index2 - index1 == 1 && index2 % 3 != 1) return true;
    if (index2 - index1 == 3) return true;
    return false;
  }
}
