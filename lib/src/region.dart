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

  /// Compute the set of values in the possible combinations for a region
  List<List<int>> regionCombinations() {
    var setValues = <int>[];
    var axisValues = <String, List<int>>{};
    var combinations = _regionCombinations(0, total, setValues, axisValues);
    return combinations;
  }

  /// Compute the set of values in the possible combinations for a region
  /// Region may or may not have a total
  /// index - index of next cell in region to process
  /// total - total value for remaining cells in region
  /// setValues - the set of values in the combinations so far
  /// returns the set of values in the combinations
  List<List<int>> _regionCombinations(int index, int total, List<int> setValues,
      Map<String, List<int>> axisValues) {
    var regionCells = this.cells;
    var newCombinations = <List<int>>[];
    final regionCell = regionCells[index];
    valueLoop:
    for (var value = 1; value < 10; value++) {
      if (regionCell.possible[value]) {
        // Check if no duplicates allowed
        if (this.nodups) {
          if (setValues.contains(value)) continue valueLoop;
        } else {
          // Check if Row, Column or Box have duplicate for this region
          for (var axis in ['R', 'C', 'B']) {
            var label = regionCell.getAxisName(axis);
            if (axisValues.containsKey(label) &&
                axisValues[label]!.contains(value)) continue valueLoop;
          }
        }

        if (index + 1 == regionCells.length) {
          if (total == value || total == 0) {
            setValues.add(value);
            newCombinations.add(setValues);
            break;
          }
        } else if (total > value || total == 0) {
          // Record values for Row, Column or Box for this region
          var newAxisValues = axisValues;
          if (!this.nodups) {
            newAxisValues = Map<String, List<int>>.from(axisValues);
            for (var label in newAxisValues.keys) {
              newAxisValues[label] = List.from(newAxisValues[label]!);
            }
            for (var axis in ['R', 'C', 'B']) {
              var label = regionCell.getAxisName(axis);
              if (!newAxisValues.containsKey(label))
                newAxisValues[label] = <int>[];
              newAxisValues[label]!.add(value);
            }
          }
          // find combinations for reduced total in remaining cells
          var remainingTotal = total == 0 ? 0 : total - value;
          var combinations = _regionCombinations(
              index + 1, remainingTotal, [...setValues, value], newAxisValues);
          newCombinations.addAll(combinations);
        }
      }
    }
    return newCombinations;
  }
}
