import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class NakedGroupStrategy extends Strategy {
  int min = 2;
  int max = 4;
  NakedGroupStrategy(sudoku) : super(sudoku, 'Naked Group');
  factory NakedGroupStrategy.minMax(sudoku, min, max) {
    var strategy = NakedGroupStrategy(sudoku);
    strategy.min = min;
    strategy.max = max;
    return strategy;
  }

  bool solve() {
    var updated = false;
    for (var axis in ['B', 'R', 'C']) {
      for (var major = 1; major < 10; major++) {
        var cells = sudoku.getMajorAxis(axis, major);
        if (nonetNakedGroup(cells)) updated = true;
      }
    }
    return updated;
  }

  bool nonetNakedGroup(List<Cell> cells) {
    var anyUpdate = false;
    // Check cells for groups
    // Ignore known cells
    var possibleCells = cells.where((cell) => !cell.isSet).toList();
    var groupMax = (possibleCells.length + 1) ~/ 2;
    //var groupMax = possibleCells.length - 1;
    if (groupMax > this.max) groupMax = this.max;
    var groupMin = this.min;
    if (groupMax < groupMin) return false;

    // Check for groups of 2 to groupMax cells
    var updated = true;
    while (updated) {
      updated = false;
      for (var gl = groupMin; gl <= groupMax; gl++) {
        var groups = findGroups(possibleCells, gl, [], 0);
        for (var group in groups) {
          var possible = unionCellsPossible(group);
          // Remove group from other cells
          for (var i = 0; i < possibleCells.length; i++) {
            var c = possibleCells[i];
            if (!group.contains(c)) {
              if (c.removePossible(possible)) {
                updated = true;
                anyUpdate = true;
                sudoku.cellUpdated(
                    c, explanation, "remove group $possible from $c");
              }
            }
          }
        }
      }
    }
    return anyUpdate;
  }

  ///
  /// Recursive function to compute Groups (Pairs, Triples, etc) of possible values
  /// pC - list of cells to check
  /// g - required group size
  /// sC - current cells in group
  /// f - next index in check cells to try
  /// Returns list of groups, each of which is a list of cells
////
  List<List<Cell>> findGroups(List<Cell> pC, int g, List<Cell> sC, int f) {
    var groups = <List<Cell>>[];
    for (var index = f; index < pC.length; index++) {
      var c = pC[index];
      if (!sC.contains(c) && c.possibleCount <= g) {
        var newSC = [...sC, c];
        var possible = unionCellsPossible(newSC);
        if (possible.count <= g) {
          if (newSC.length == g) {
            groups.add(newSC);
          } else {
            // try adding cells to group
            var newGroups = findGroups(pC, g, newSC, index + 1);
            if (newGroups.length > 0) {
              groups.addAll(newGroups);
            }
          }
        }
      }
    }
    return groups;
  }
}
