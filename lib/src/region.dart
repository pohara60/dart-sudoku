import 'package:sudoku/src/cell.dart';

abstract class Region<Puzzle> {
  Puzzle puzzle;
  Cells cells;
  String name;
  int total;
  bool nodups;
  Map<int, Set<Cell>> mandatory;
  Region(Puzzle this.puzzle, String this.name, int this.total, bool this.nodups,
      Cells this.cells)
      : mandatory = Map<int, Set<Cell>>();
  String toString();

  bool equals(Region other) {
    // Equal if cells are same
    if (this.cells.length == other.cells.length &&
        this.cells.every(
            (cell) => other.cells.any((otherCell) => otherCell == cell))) {
      return true;
    }
    return false;
  }

  /// Compute the set of values in the possible combinations for a region
  List<List<int>>? regionCombinations() {
    var combinations = nextRegionCombinations(
      0,
      total,
      <int>[],
      <String, List<int>>{},
      remainingOptionalTotal,
      validOptionalTotal,
      false, // unlimited
    );
    return combinations;
  }

  /// Compute the set of values in the possible combinations for a region
  /// Region may or may not have a total
  /// index - index of next cell in region to process
  /// total - total value for remaining cells in region
  /// setValues - the set of values in the combinations so far
  /// remainingTotal - function to update total for each value
  /// returns the set of values in the combinations
  List<List<int>>? nextRegionCombinations(
      int index,
      int total,
      List<int> setValues,
      Map<String, List<int>>? axisValues,
      int remainingTotal(int total, int value, int index),
      bool validTotal(int total, int value),
      [bool limited = true,
      int validValues(List<int> values)?]) {
    var combinationCount = Limiter(limited ? COMBINATION_LIMIT : null);
    var iterationCount = Limiter(limited ? ITERATION_LIMIT : null);
    // var stopwatch = Stopwatch();
    // stopwatch.start();
    try {
      var combinations = cellCombinations(
        this.cells,
        this.nodups,
        this.mandatory,
        index,
        total,
        setValues,
        axisValues,
        remainingTotal,
        validTotal,
        combinationCount,
        iterationCount,
        validValues,
      );
      // stopwatch.stop();
      // print(
      //     'combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      return combinations;
    } catch (e) {
      // stopwatch.stop();
      // print(
      //     'exception combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      return null;
    }
  }
}

abstract class RegionGroup<Puzzle> extends Region<Puzzle> {
  String nonet;
  List<Region> regions;
  RegionGroup(Puzzle puzzle, String name, String this.nonet, nodups,
      List<Region> this.regions, Cells cells)
      : super(puzzle, name, 0, nodups, cells);

  String toString() {
    var regions = this.regions.map<String>((r) => r.name);
    var text =
        '$name ${nonet != '' ? '$nonet,' : ''}$regions:${cells.cellsString()}';
    return text;
  }

  bool equalsGroup(RegionGroup other) {
    // Equal if cells are same
    if (this.regions.length == other.regions.length &&
        this.regions.every((region) =>
            other.regions.any((otherRegion) => otherRegion == region))) {
      return true;
    }
    return false;
  }

  List<List<int>>? regionGroupCombinations(String explanation) {
    var combinations = nextRegionCombinations(
      0,
      this.total,
      <int>[],
      <String, List<int>>{},
      remainingOptionalTotal,
      validOptionalTotal,
    );
    return combinations;
  }
}

/// Callback functions for cellCombinations
bool validNoTotal(_, value) => true;
bool validExactTotal(total, value) => total == value;
bool validOptionalTotal(total, value) => total == 0 || total == value;
bool validMaxTotal(maximum, value) => maximum >= value;
bool validArrowTotal(total, value) => total == value;
int remainingNoTotal(_, value, index) => 0;
int remainingExactTotal(total, value, index) => total - value;
int remainingOptionalTotal(total, value, index) =>
    total == 0 ? 0 : total - value;
int remainingMaxTotal(maximum, value, index) => maximum - value;
int remainingArrowTotal(total, value, index) =>
    index == 0 ? value : total - value;

// Limit on number of combinations to return
var COMBINATION_LIMIT = 10000;
var ITERATION_LIMIT = 100000;

/// Compute the set of values in the possible combinations for cells
/// cells - the cells
/// nodups - no duplicates
/// mandatory - mandatory values in cells
/// index - index of next cell in region to process
/// total - total value for remaining cells in region
/// setValues - the set of values in the combinations so far
/// remainingTotal - function to update total for each value
/// returns the set of values in the combinations
List<List<int>> cellCombinations(
  Cells cells,
  bool nodups,
  Map<int, Set<Cell>>? mandatory,
  int index,
  int total,
  List<int> setValues,
  Map<String, List<int>>? axisValues,
  int remainingTotal(int total, int value, int index),
  bool validTotal(int total, int value), [
  Limiter? combinationLimiter,
  Limiter? iterationLimiter,
  int validValues(List<int> values)?,
]) {
  var regionCells = cells;
  assert(nodups || axisValues != null);
  var newCombinations = <List<int>>[];
  final regionCell = regionCells[index];
  valueLoop:
  for (var value = 1; value < 10; value++) {
    if (regionCell.possible[value]) {
      // Check if no duplicates allowed
      if (nodups) {
        if (setValues.contains(value)) continue valueLoop;
      } else {
        // Check if Row, Column or Box have duplicate for this region
        for (var axis in ['R', 'C', 'B']) {
          var label = regionCell.getAxisName(axis);
          if (axisValues!.containsKey(label) &&
              axisValues[label]!.contains(value)) continue valueLoop;
        }
      }

      // Value validation
      var combination = [...setValues, value];
      if (validValues != null) {
        var valid = validValues(combination);
        if (valid > 0) continue valueLoop;
        if (valid < 0) break;
      }
      // Exceeds iteration limit?
      if (iterationLimiter != null) iterationLimiter.increment();

      // Finished combination?
      if (index + 1 == regionCells.length) {
        // Check region total, if any
        var valid = validTotal(total, value);
        if (valid) {
          // Check region mandatory, if any
          if (mandatory == null ||
              mandatory.entries.every((entry) {
                var index = combination.indexOf(entry.key);
                return (index != -1 && entry.value.contains(cells[index]));
              })) {
            // New combination OK
            // Exceeds limit?
            if (combinationLimiter != null) combinationLimiter.increment();

            newCombinations.add(combination);
            if (total > 0 && validTotal != validMaxTotal) {
              // Exact value required, so can break
              break;
            } else {
              // Loop to get more combinations
              continue valueLoop;
            }
          }
        }
      } else if (total > value || total == 0) {
        // Record values for Row, Column or Box for this region
        var newAxisValues = axisValues;
        if (!nodups) {
          newAxisValues = Map<String, List<int>>.from(axisValues!);
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
        var remaining = remainingTotal(total, value, index);
        var combinations = cellCombinations(
          cells,
          nodups,
          mandatory,
          index + 1,
          remaining,
          [...setValues, value],
          newAxisValues,
          remainingTotal,
          validTotal,
          combinationLimiter,
          iterationLimiter,
          validValues,
        );
        newCombinations.addAll(combinations);
      }
    }
  }
  return newCombinations;
}

class Limiter {
  int count = 0;
  int? limit;
  Limiter([this.limit]);
  void increment() {
    count++;
    if (limit != null && count > limit!) {
      throw LimitException;
    }
  }

  String toString() {
    return '$count' + (limit == null ? '' : '/$limit!');
  }
}

class LimitException implements Exception {
  LimitException();
}
