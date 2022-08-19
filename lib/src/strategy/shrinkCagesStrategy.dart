import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/killerRegion.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class ShrinkCagesStrategy extends Strategy {
  ShrinkCagesStrategy(Puzzle puzzle) : super(puzzle, 'Shrink Cages') {
    assert(puzzle.runtimeType == Killer);
  }

  static int _shrinkSeq = 1; // Numbering for new cages

  bool solve() {
    var killer = puzzle as Killer;
    var updated = false;
    for (var cage in killer.cages) {
      // Look at overlapping cages to see if the cage can be split
      var newCells = List<Cell>.from(cage.cells);
      var newTotal = cage.total;
      for (var cageCell in cage.cells) {
        for (var otherCage
            in killer.getAllCages(cageCell).where((c) => c != cage)) {
          // Get intersection
          var intersection = intersectionCells(otherCage.cells, newCells);
          var thisRemainder = remainderCells(newCells, otherCage.cells);
          var otherRemainder = remainderCells(otherCage.cells, newCells);
          // If not fixed and other remainder is fixed,
          var intersectionTotal = fixedTotalCells(intersection);
          var thisRemainderTotal = fixedTotalCells(thisRemainder);
          var otherRemainderTotal = fixedTotalCells(otherRemainder);
          if (intersectionTotal == 0 &&
              thisRemainderTotal == 0 &&
              otherRemainderTotal > 0) {
            // Subtract intersection from cage
            intersectionTotal = otherCage.total - otherRemainderTotal;
            newCells = remainderCells(newCells, intersection);
            newTotal -= intersectionTotal;
          }
        }
      }
      // Create new cage
      if (newTotal > 0 && newTotal != cage.total) {
        var nodups = cellsInNonet(newCells);
        var newCage = KillerRegion(
          killer,
          'KS${_shrinkSeq++}',
          newTotal,
          newCells,
          true,
          nodups,
          cage.source,
        );
        updated = true;
        sudoku.addMessage(addExplanation(explanation, 'new cage $newCage'));
      }
    }
    // If any updates then next run of killer combinations will update them
    return updated;
  }
}
