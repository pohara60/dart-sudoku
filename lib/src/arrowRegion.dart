import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/arrow.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/region.dart';

class ArrowRegion extends Region<Arrow> {
  ArrowRegion(Arrow arrow, String name, Cells cells, {nodups = true})
      : super(arrow, name, 0, nodups, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  Arrow get arrow => puzzle;

  toString() {
    var sortedCells = cells;
    var text = '$name:${sortedCells.cellsString()}';
    return text;
  }

  @override
  List<List<int>>? regionCombinations() {
    var combinations = nextRegionCombinations(
      0,
      0,
      <int>[],
      <String, List<int>>{},
      remainingArrowTotal,
      validArrowTotal,
    );
    return combinations;
  }

  static int validArrowGroupValues(
      List<int> values, Cells valueCells, Cells cells, Puzzle puzzle,
      [List<Region>? regions]) {
    var arrow = puzzle as Arrow;

    // Check arrow for cells in order
    var doneRegions = <ArrowRegion>[];
    var latestCell = valueCells[values.length - 1];
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      var cell = valueCells[valueIndex];
      var value = values[valueIndex];
      // Check arrow sequence
      for (var arrowRegion in arrow.getArrows(cell).where((arrowRegion) =>
          !doneRegions.contains(arrowRegion) &&
          (regions == null || regions.contains(arrowRegion)))) {
        var index = arrowRegion.cells.indexOf(cell);
        assert(index != -1);
        var arrowValues = List<int>.filled(arrowRegion.cells.length, 0);
        arrowValues[index] = value;
        // Check if other cells in arrow have values
        for (var priorValueIndex = valueIndex - 1;
            priorValueIndex >= 0;
            priorValueIndex--) {
          var priorCell = valueCells[priorValueIndex];
          var priorValue = values[priorValueIndex];
          var priorIndex = arrowRegion.cells.indexOf(priorCell);
          if (priorIndex != -1) {
            // In arrow
            arrowValues[priorIndex] = priorValue;
          }
        }
        // Do we have all arrow cells?
        var totalValue = arrowValues[0];
        var otherValues = arrowValues.sublist(1);
        var allValues = otherValues.every((element) => element != 0);
        var sumValues = otherValues.fold<int>(
            0, (previousValue, value) => previousValue + value);
        if (totalValue != 0) {
          if (allValues) {
            if (sumValues < totalValue) {
              // Need higher sum
              if (arrowRegion.cells.contains(latestCell)) return 1;
              return -1;
            } else if (sumValues > totalValue) {
              // Need higher total
              if (latestCell == arrowRegion.cells[0]) return 1;
              return -1;
            }
          } else {
            if (sumValues > totalValue) {
              // Need higher total
              if (latestCell == arrowRegion.cells[0]) return 1;
              return -1;
            }
          }
        } else {
          if (sumValues > 9) {
            return -1;
          }
        }

        doneRegions.add(arrowRegion);
      }
    }
    return 0;
  }
}

class ArrowRegionGroup extends RegionGroup {
  ArrowRegionGroup(Arrow puzzle, String name, String nonet, bool nodups,
      List<Region> regions, Cells cells)
      : super(puzzle, name, nonet, nodups, regions, cells);

  Arrow get arrow => puzzle;

  @override
  List<List<int>>? regionGroupCombinations(String explanation) {
    // Get maximum value of arrow totals
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
    // Get combinations for arrow lines
    // Limited to maximum
    var arrowCells = this.cells;
    combinationCount = Limiter(COMBINATION_LIMIT);
    iterationCount = Limiter(ITERATION_LIMIT);
    // var stopwatch = Stopwatch();
    // stopwatch.start();
    try {
      var arrowCombinations = cellCombinations(
        arrowCells,
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
      // Get minimum total of arrowCombinations
      var arrowMin = arrowCombinations.fold<int>(arrowCells.length * 9,
          (min, combination) {
        var minimum = combination.fold<int>(0, (total, value) => total + value);
        return minimum < min ? minimum : min;
      });
      // If arrow minimum is greater than total minimum, then update arrow totals
      if (arrowMin > totalMin) {
        var newTotalCombinations = totalCombinations.where((combination) =>
            combination.fold<int>(0, (total, value) => total + value) >=
            arrowMin);
        if (newTotalCombinations.length < totalCombinations.length) {
          // Update possible - cannot handle result
          puzzle.sudoku.updateCellCombinations(
              totalCells, newTotalCombinations.toList(), explanation);
        }
      }
      return arrowCombinations;
    } catch (e) {
      // stopwatch.stop();
      // print(
      //     'exception combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      return null;
    }
  }
}
