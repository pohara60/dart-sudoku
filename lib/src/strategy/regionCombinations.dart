import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/strategy.dart';
import 'package:sudoku/src/sudoku.dart';

/// Find combinations of values for each Killer Cage (Region)
class RegionCombinationsStrategy extends Strategy {
  RegionCombinationsStrategy(Puzzle puzzle)
      : super(puzzle, 'Region Combinations') {}

  bool solve() {
    var updated = false;
    for (var region in sudoku.regions) {
      var location = addExplanation(explanation, '$region');
      var combinations = region.regionCombinations();
      // Update possible values to union of combinations
      // Update possible values to union of combinations
      if (sudoku.updateCellCombinations(region.cells, combinations, location))
        updated = true;
    }
    return updated;
  }
}
