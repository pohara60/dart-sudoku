import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/strategy.dart';
import 'package:sudoku/src/sudoku.dart';

/// Find combinations of values for each Killer Cage (Region)
class RegionGroupCombinationsStrategy extends Strategy {
  RegionGroupCombinationsStrategy(Puzzle puzzle)
      : super(puzzle, 'Region Group Combinations') {}

  bool solve() {
    var updated = false;
    for (var region in sudoku.regionGroups) {
      // Check for RegionGroup subtypes
      var location = addExplanation(explanation, '$region');
      var combinations = region.regionGroupCombinations(location);
      // Null means could not compute combinations for region
      if (combinations == null) continue;
      // Update possible values to union of combinations
      if (sudoku.updateCellCombinations(region.cells, combinations, location))
        updated = true;
    }
    return updated;
  }
}
