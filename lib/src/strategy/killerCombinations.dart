import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/possible.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class KillerCombinationsStrategy extends Strategy {
  KillerCombinationsStrategy(Puzzle puzzle)
      : super(puzzle, 'Killer Combinations') {
    assert(puzzle.runtimeType == Killer);
  }

  bool solve() {
    var killer = puzzle as Killer;
    var updated = false;
    for (var cage in killer.cages) {
      var total = cage.total;
      var setValues = <int>[];
      var axisValues = <String, List<int>>{};
      var combinations =
          cage.findCageCombinations(0, total, setValues, axisValues);
      // Update possible values to union of combinations
      var unionCombinations =
          List.generate(cage.cageCells.length, (index) => Possible(false));
      for (var combination in combinations) {
        for (var index = 0; index < combination.length; index++) {
          var value = combination[index];
          unionCombinations[index][value] = true;
        }
      }
      for (var index = 0; index < cage.cageCells.length; index++) {
        var cell = cage.cageCells[index].cell;
        if (cell.reducePossible(unionCombinations[index])) {
          updated = true;
          grid.cellUpdated(cell, explanation, 'cage $cage $cell');
        }
      }
    }
    return updated;
  }
}
