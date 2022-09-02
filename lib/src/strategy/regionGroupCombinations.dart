import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/strategy/strategy.dart';
import 'package:sudoku/src/sudoku.dart';

/// Find combinations of values for each Killer Cage (Region)
class RegionGroupCombinationsStrategy extends Strategy {
  RegionGroupCombinationsStrategy(Puzzle puzzle)
      : super(puzzle, 'Region Group Combinations') {}

  bool solve() {
    var updated = false;
    for (var region in sudoku.regions) {
      // Check for RegionGroup subtypes
      if (region is RegionGroup) {
        var location = addExplanation(explanation, '$region');
        var combinations = region.regionGroupCombinations(location);
        // Update possible values to union of combinations
        var cells = [...region.cells, ...region.outies];
        if (sudoku.updateCellCombinations(cells, combinations, location))
          updated = true;
      }
    }
    return updated;
  }
}
