import 'package:collection/collection.dart';

import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/possible.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class HiddenGroupStrategy extends Strategy {
  int min = 2;
  int max = 4;
  HiddenGroupStrategy(sudoku) : super(sudoku, 'Hidden Group');
  factory HiddenGroupStrategy.minMax(sudoku, min, max) {
    var strategy = HiddenGroupStrategy(sudoku);
    strategy.min = min;
    strategy.max = max;
    return strategy;
  }

  bool solve() {
    var updated = false;
    for (var axis in ['R', 'C', 'B']) {
      for (var major = 1; major < 10; major++) {
        var cells = sudoku.getMajorAxis(axis, major);
        if (nonetHiddenGroup(cells)) updated = true;
      }
    }
    return updated;
  }

  bool nonetHiddenGroup(List<Cell> cells) {
    var possibleCells = cells.where((cell) => !cell.isSet).toList();
    var valuesPossible = getValuesPossible(possibleCells);
    // Ignore known values
    var possibleValues = valuesPossible
        .expandIndexed<int>(
            (index, cells) => cells.count != 0 ? [index + 1] : [])
        .toList();
    var groupMax = possibleValues.length ~/ 2;
    //var groupMax = possibleValues.length - 1;
    if (groupMax > this.max) groupMax = this.max;
    var groupMin = this.min;
    if (groupMax < groupMin) return false;

    // Check for groups of 2 to groupMax values
    var anyUpdate = false;
    var updated = true;
    while (updated) {
      updated = false;
      var smallerGroups = [];
      for (var gl = 2; gl <= groupMax; gl++) {
        var groups = findGroups(possibleValues, gl, [], 0, valuesPossible);
        if (gl >= groupMin) {
          for (var group in groups) {
            var possible = unionValuesPossible(group);
            // Check if group is a superset of a smaller group
            var superset = false;
            for (var smallerGroup in smallerGroups) {
              var smallerPossible = unionValuesPossible(smallerGroup);
              if (smallerPossible.subtract(possible).count == 0) {
                superset = true;
              }
            }
            if (!superset) {
              var groupCells =
                  unionValuesCells(valuesPossible, group, possibleCells);
              // Remove other values from group cells
              for (var i = 0; i < groupCells.length; i++) {
                var c = groupCells[i];

                if (c.removeOtherPossible(possible)) {
                  updated = true;
                  anyUpdate = true;
                  sudoku.cellUpdated(c, explanation, "set $c");
                }
              }
            }
          }
        }
        smallerGroups.addAll(groups);
      }
    }
    return anyUpdate;
  }

  ///
  /// Recursive function to compute Groups (Pairs, Triples, etc) of possible values
  /// pV - list of values to check
  /// g - required group size
  /// sV - current values in group
  /// f - next index in check values to try
  /// Returns list of groups, each of which is a list of values
////
  List<List<int>> findGroups(
      List<int> pV, int g, List<int> sV, int f, List<Possible> valuesPossible) {
    var groups = <List<int>>[];
    for (var index = f; index < pV.length; index++) {
      var value = pV[index];
      if (!sV.contains(value) &&
          // Don't include naked/hidden singles
          valuesPossible[value - 1].count > 1 &&
          valuesPossible[value - 1].count <= g) {
        var newSV = [...sV, value];
        var possible = unionPossible(
            newSV.map((value) => valuesPossible[value - 1]).toList(), 0);
        if (possible.count <= g) {
          if (newSV.length == g) {
            groups.add(newSV);
          } else {
            // try adding cells to group
            var newGroups = findGroups(pV, g, newSV, index + 1, valuesPossible);
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

List<Cell> unionValuesCells(
    List<Possible> valuesPossible, List<int> group, List<Cell> cells) {
  var possibles = <Possible>[];
  for (var value in group) {
    possibles.add(valuesPossible[value - 1]);
  }
  var union = unionPossible(possibles, 0);
  var unionCells = cells.whereIndexed((index, cell) => union[index]);
  return unionCells.toList();
}

Possible unionValuesPossible(List<int> group) {
  var possible = Possible(false);
  for (var value in group) {
    possible[value] = true;
  }
  return possible;
}

/// Compute possible cells for values
/// Inverts normal meaning of Possible
List<Possible> getValuesPossible(List<Cell> cells) {
  var result = List<Possible>.generate(9, (index) => Possible(false, 0));
  cells.where((cell) => !cell.isSet).forEachIndexed((index, cell) {
    for (var value = 1; value < 10; value++) {
      if (cell.isPossible(value)) {
        result[value - 1][index] = true;
      }
    }
  });
  return result;
}
