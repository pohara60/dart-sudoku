import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/strategy.dart';
import 'package:sudoku/src/sudoku.dart';

/// Colour regions that support it, i.e. whisper, entropy
class RegionColouringStrategy extends Strategy {
  RegionColouringStrategy(Puzzle puzzle) : super(puzzle, 'Region Colouring') {}

  bool solve() {
    var updated = false;
    for (var region in sudoku.regions) {
      var location = addExplanation(explanation, '$region');
      if (region.regionColouring(location)) updated = true;
    }
    return updated;
  }
}
