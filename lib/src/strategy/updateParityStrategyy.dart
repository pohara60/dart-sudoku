import 'package:sudoku/src/domino.dart';
import 'package:sudoku/src/parityRegion.dart';
import 'package:sudoku/src/strategy/strategy.dart';

import '../cell.dart';
import '../dominoRegion.dart';
import '../killerRegion.dart';
import '../puzzle.dart';
import '../sudoku.dart';

/// Check parity in a Domino puzzle
class UpdateParityStrategy extends Strategy {
  UpdateParityStrategy(Puzzle puzzle) : super(puzzle, 'Update Parity');

  bool solve() {
    // Should only apply to Domino puzzles
    if (!(puzzle is Domino)) return false;

    var domino = puzzle as Domino;
    if (![DominoType.DOMINO_O, DominoType.DOMINO_E]
        .any((type) => domino.dominoTypes.contains(type))) return false;

    var updated = false;
    var root = domino.parityRegions![sudoku.allRegions['G']!]!;
    updated = updateParity(root);

    for (var parityRegion in domino.parityRegions!.values
        .where((parityRegion) => parityRegion.parents.isEmpty)) {
      if (parityRegion != root) {
        if (updateParity(parityRegion)) updated = true;
      }
    }
    return updated;
  }

  bool updateParity(ParityRegion parityRegion) {
    bool updated = false;
    var region = parityRegion.region;
    var location = addExplanation(explanation, 'region $region');

    // Combine parity of child regions
    var childParity = Parity.EVEN;
    for (var childParityRegion in parityRegion.children) {
      if (childParityRegion.region is SudokuRegion ||
          childParityRegion.region is KillerRegion) {
        if (updateParity(childParityRegion)) updated = true;
      } else if (childParityRegion.region is DominoRegion) {
        // Fixed parity
      }
      childParity = combineParity(childParity, childParityRegion.parity);
    }

    // Look at unknown child cells
    var cellsParity = combineParity(parityRegion.parity, childParity);
    var cells = parityRegion.cells;
    if (cells != null && cells.isNotEmpty) {
      var unknownCells = <Cell>[];
      for (var cell in cells) {
        if (cell.isEven())
          cellsParity = combineParity(cellsParity, Parity.EVEN);
        else if (cell.isOdd())
          cellsParity = combineParity(cellsParity, Parity.ODD);
        else
          unknownCells.add(cell);
      }
      // One unknown can be set by parity
      if (unknownCells.length == 1) {
        var cell = unknownCells.first;
        if (cellsParity == Parity.ODD) {
          if (cell.setOdd()) updated = true;
        }
        if (cellsParity == Parity.EVEN) {
          if (cell.setEven()) updated = true;
        }
        if (updated) {
          sudoku.cellUpdated(cell, location, 'cells $cellsParity $cell');
        }
      }
    }

    // If region has 9 cells (B/R/C or perhaps K) then check count
    // This will normally be done by Naked Group, but sometimes happens
    // here when the logic aboved set the last cell parity
    if (region.cells.length == 9) {
      var evenCells = region.cells.where((cell) => cell.isEven());
      var countEven = evenCells.length;
      var oddCells = region.cells.where((cell) => cell.isOdd());
      var countOdd = oddCells.length;
      if ((countEven + countOdd) != 9) {
        if (countEven == 4) {
          for (var cell
              in region.cells.where((cell) => !evenCells.contains(cell))) {
            if (cell.setOdd()) {
              updated = true;
              sudoku.cellUpdated(cell, location, 'cells count E $cell');
            }
          }
        }
        if (countOdd == 5) {
          for (var cell
              in region.cells.where((cell) => !oddCells.contains(cell))) {
            if (cell.setEven()) {
              updated = true;
              sudoku.cellUpdated(cell, location, 'cells count O $cell');
            }
          }
        }
      }
    }

    return updated;
  }
}

Parity combineParity(newParity, Parity parity) {
  if (parity == Parity.ODD && newParity == Parity.ODD) return Parity.EVEN;
  if (parity == Parity.EVEN && newParity == Parity.EVEN) return Parity.EVEN;
  if (parity == Parity.ODD && newParity == Parity.EVEN) return Parity.ODD;
  if (parity == Parity.EVEN && newParity == Parity.ODD) return Parity.ODD;
  return Parity.UNKNOWN;
}
