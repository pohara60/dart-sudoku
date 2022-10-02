import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/domino.dart';
import 'package:sudoku/src/region.dart';

enum DominoType {
  DOMINO_X, // Add to 10
  DOMINO_V, // Add to 5
  DOMINO_C, // Consecutive
  DOMINO_M, // MUltiple 2
  DOMINO_O, // Odd parity
  DOMINO_E; // Even parity

  String toString() => this.name.substring(this.name.length - 1);
}

class DominoRegion extends Region<Domino> {
  final DominoType type;
  DominoRegion(
      Domino domino, String name, DominoType this.type, List<Cell> cells,
      {nodups = true})
      : super(
          domino,
          name,
          type == DominoType.DOMINO_X
              ? 10
              : type == DominoType.DOMINO_V
                  ? 5
                  : 0,
          nodups,
          cells,
        ) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  Domino get domino => puzzle;

  toString() {
    var sortedCells = cells;
    var text = '$name:${cellsString(sortedCells)}';
    return text;
  }

  @override
  List<List<int>>? regionCombinations() {
    var combinations = nextRegionCombinations(
      0,
      0,
      <int>[],
      <String, List<int>>{},
      remainingOptionalTotal,
      validOptionalTotal,
      false, // unlimited
      validDominoValues,
    );
    return combinations;
  }

  int validDominoValues(List<int> values) {
    // Check Consecutive and Multiple, X/V checked by total logic
    if (type == DominoType.DOMINO_X && type == DominoType.DOMINO_V) return 0;

    // Check for domino from prior cell
    if (values.length < 2) return 0;

    var value = values[values.length - 1];
    var otherValue = values[values.length - 2];
    if (type == DominoType.DOMINO_C) {
      var diff = value - otherValue;
      if (diff < -1) return 1; // continue processing higher values
      if (diff > 1) return -1; // break processing higher values
      return 0;
    }
    if (type == DominoType.DOMINO_M) {
      if (value > otherValue) {
        var multiple = value ~/ otherValue;
        var remainder = value % otherValue;
        if (multiple < 2) return 1; // continue processing higher values
        if (multiple > 2 || remainder > 0)
          return -1; // break processing higher values
        return 0;
      } else {
        var multiple = otherValue ~/ value;
        var remainder = otherValue % value;
        if (multiple < 2) return -1; // break processing higher values
        if (multiple > 2 || remainder > 0)
          return 1; // continue processing higher values
        return 0;
      }
    }
    if (type == DominoType.DOMINO_O) {
      var sum = value + otherValue;
      if (sum % 2 != 1) return 1; // continue processing higher values
      return 0;
    }
    if (type == DominoType.DOMINO_E) {
      var sum = value + otherValue;
      if (sum % 2 != 0) return 1; // continue processing higher values
      return 0;
    }
    return 0;
  }
}

class DominoRegionGroup extends RegionGroup {
  DominoRegionGroup(Domino puzzle, String name, String nonet, bool nodups,
      List<Region> regions, List<Cell> cells)
      : super(puzzle, name, nonet, nodups, regions, cells);

  Domino get domino => puzzle;

  @override
  List<List<int>>? regionGroupCombinations(String explanation) {
    // Get maximum value of domino totals
    var totalCells =
        this.regions.expand((region) => [region.cells[0]]).toList();
    var combinationCount = Limiter();
    var iterationCount = Limiter();
    var totalCombinations = cellCombinations(
      totalCells,
      false,
      null,
      0,
      0,
      <int>[],
      <String, List<int>>{},
      remainingNoTotal,
      validNoTotal,
      combinationCount,
      iterationCount,
    );
    // print('combinations=$combinationCount, iterations=$iterationCount');
    var totalMin =
        totalCombinations.fold<int>(totalCells.length * 9, (min, combination) {
      var minimum = combination.fold<int>(0, (total, value) => total + value);
      return minimum < min ? minimum : min;
    });
    var totalMax = totalCombinations.fold<int>(0, (max, combination) {
      var maximum = combination.fold<int>(0, (total, value) => total + value);
      return maximum > max ? maximum : max;
    });
    // Get combinations for domino lines
    // Limited to maximum
    var dominoCells = this.cells;
    combinationCount = Limiter(COMBINATION_LIMIT);
    iterationCount = Limiter(ITERATION_LIMIT);
    // var stopwatch = Stopwatch();
    // stopwatch.start();
    try {
      var dominoCombinations = cellCombinations(
        dominoCells,
        false,
        null,
        0,
        totalMax,
        <int>[],
        <String, List<int>>{},
        remainingMaxTotal,
        validMaxTotal,
        combinationCount,
        iterationCount,
      );
      // stopwatch.stop();
      // print(
      //     'combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      // Get minimum total of dominoCombinations
      var dominoMin = dominoCombinations.fold<int>(dominoCells.length * 9,
          (min, combination) {
        var minimum = combination.fold<int>(0, (total, value) => total + value);
        return minimum < min ? minimum : min;
      });
      // If domino minimum is greater than total minimum, then update domino totals
      if (dominoMin > totalMin) {
        var newTotalCombinations = totalCombinations.where((combination) =>
            combination.fold<int>(0, (total, value) => total + value) >=
            dominoMin);
        if (newTotalCombinations.length < totalCombinations.length) {
          // Update possible - cannot handle result
          puzzle.sudoku.updateCellCombinations(
              totalCells, newTotalCombinations.toList(), explanation);
        }
      }
      return dominoCombinations;
    } catch (e) {
      // stopwatch.stop();
      // print(
      //     'exception combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      return null;
    }
  }
}
