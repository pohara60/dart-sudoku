import 'package:collection/collection.dart';

import 'package:sudoku/src/possible.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// Find combinations of values for each Killer Cage (Region)
class RegionCombinationsStrategy extends Strategy {
  RegionCombinationsStrategy(Puzzle puzzle)
      : super(puzzle, 'Region Combinations') {}

  bool solve() {
    var updated = false;
    for (var region in sudoku.regions) {
      var combinations = region.regionCombinations();
      // Update possible values to union of combinations
      assert(combinations.length > 0);
      var unionCombinations =
          List.generate(region.cells.length, (index) => Possible(false));
      for (var combination in combinations) {
        for (var index = 0; index < combination.length; index++) {
          var value = combination[index];
          unionCombinations[index][value] = true;
        }
      }
      region.cells.forEachIndexed((index, cell) {
        if (cell.reducePossible(unionCombinations[index])) {
          updated = true;
          sudoku.cellUpdated(cell, explanation, '$region $cell');
        }
      });
    }
    return updated;
  }
}
