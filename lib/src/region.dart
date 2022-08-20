import 'package:sudoku/src/cell.dart';

abstract class Region<Puzzle> {
  Puzzle puzzle;
  List<Cell> cells;
  String name;
  int total;
  bool nodups;
  Region(Puzzle this.puzzle, String this.name, int this.total, bool this.nodups,
      List<Cell> this.cells);
  String toString();

  /// Compute the set of values in the possible combinations for a cage
  /// index - index of next cell in cage to process
  /// total - total value for remaining cells in cage
  /// setValues - the set of values in the combinations so far
  /// returns the set of values in the combinations
  List<List<int>> regionCombinations() {
    var setValues = <int>[];
    var axisValues = <String, List<int>>{};
    var combinations = _regionCombinations(0, total, setValues, axisValues);
    return combinations;
  }

  List<List<int>> _regionCombinations(int index, int total, List<int> setValues,
      Map<String, List<int>> axisValues) {
    var cageCells = this.cells;
    var newCombinations = <List<int>>[];
    final cageCell = cageCells[index];
    valueLoop:
    for (var value = 1; value < 10; value++) {
      if (cageCell.possible[value]) {
        // Check if no duplicates allowed
        if (this.nodups) {
          if (setValues.contains(value)) continue valueLoop;
        } else {
          // Check if Row, Column or Box have duplicate for this cage
          for (var axis in ['R', 'C', 'B']) {
            var label = cageCell.getAxisName(axis);
            if (axisValues.containsKey(label) &&
                axisValues[label]!.contains(value)) continue valueLoop;
          }
        }

        if (index + 1 == cageCells.length) {
          if (total == value) {
            setValues.add(value);
            newCombinations.add(setValues);
            break;
          }
        } else if (total > value) {
          // Record values for Row, Column or Box for this cage
          var newAxisValues = axisValues;
          if (!this.nodups) {
            newAxisValues = Map<String, List<int>>.from(axisValues);
            for (var label in newAxisValues.keys) {
              newAxisValues[label] = List.from(newAxisValues[label]!);
            }
            for (var axis in ['R', 'C', 'B']) {
              var label = cageCell.getAxisName(axis);
              if (!newAxisValues.containsKey(label))
                newAxisValues[label] = <int>[];
              newAxisValues[label]!.add(value);
            }
          }
          // find combinations for reduced total in remaining cells
          var combinations = _regionCombinations(
              index + 1, total - value, [...setValues, value], newAxisValues);
          newCombinations.addAll(combinations);
        }
      }
    }
    return newCombinations;
  }
}
