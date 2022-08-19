import 'package:collection/collection.dart';

import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/possible.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// Find combinations of values for each Killer Cage (Region)
class KillerCombinationsStrategy extends Strategy {
  KillerCombinationsStrategy(Puzzle puzzle)
      : super(puzzle, 'Killer Combinations') {
    assert(puzzle.runtimeType == Killer);
  }

  bool solve() {
    assert(puzzle is Killer);
    var killer = puzzle as Killer;
    var updated = false;
    for (var cage in killer.cages) {
      var combinations = cage.cageCombinations();
      // Update possible values to union of combinations
      assert(combinations.length > 0);
      var unionCombinations =
          List.generate(cage.cells.length, (index) => Possible(false));
      for (var combination in combinations) {
        for (var index = 0; index < combination.length; index++) {
          var value = combination[index];
          unionCombinations[index][value] = true;
        }
      }
      cage.cells.forEachIndexed((index, cell) {
        if (cell.reducePossible(unionCombinations[index])) {
          updated = true;
          sudoku.cellUpdated(cell, explanation, 'cage $cage $cell');
        }
      });
    }
    return updated;
  }
}
