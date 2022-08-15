import 'package:sudoku/src/cage.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class ShrinkCagesStrategy extends Strategy {
  ShrinkCagesStrategy(Puzzle puzzle) : super(puzzle, 'Shrink Cages') {
    assert(puzzle.runtimeType == Killer);
  }

  bool solve() {
    var killer = puzzle as Killer;
    var updated = false;
    for (var cage in killer.cages) {
      // Look at overlapping cages to see if the cage can be split
      var newCageCells = List<CageCell>.from(cage.cageCells);
      var newTotal = cage.total;
      for (var cageCell in cage.cageCells) {
        for (var otherCage in cageCell.cages.where((c) => c != cage)) {
          // Get intersection
          var intersection =
              intersectionCageCells(otherCage.cageCells, newCageCells);
          var thisRemainder =
              remainderCageCells(newCageCells, otherCage.cageCells);
          var otherRemainder =
              remainderCageCells(otherCage.cageCells, newCageCells);
          // If not fixed and other remainder is fixed,
          var intersectionTotal = fixedTotalCageCells(intersection);
          var thisRemainderTotal = fixedTotalCageCells(thisRemainder);
          var otherRemainderTotal = fixedTotalCageCells(otherRemainder);
          if (intersectionTotal == 0 &&
              thisRemainderTotal == 0 &&
              otherRemainderTotal > 0) {
            // Subtract intersection from cage
            intersectionTotal = otherCage.total - otherRemainderTotal;
            newCageCells = remainderCageCells(newCageCells, intersection);
            newTotal -= intersectionTotal;
          }
        }
      }
      // Create new cage
      if (newTotal > 0 && newTotal != cage.total) {
        var newCells = newCageCells.map((cageCell) => cageCell.cell).toList();
        var nodups = cellsInNonet(newCells);
        var newCage = Cage.fromCageCells(
          killer,
          newTotal,
          newCageCells,
          true,
          nodups,
          cage.source,
        );
        updated = true;
        grid.addMessage(addExplanation(explanation, 'new cage $newCage'));
      }
    }
    // If any updates then next run of killer combinations will update them
    return updated;
  }
}
