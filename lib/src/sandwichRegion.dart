import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/sandwich.dart';
import 'package:sudoku/src/region.dart';

class SandwichRegion extends Region<Sandwich> {
  SandwichRegion(Sandwich sandwich, String name, int total, Cells cells)
      : super(sandwich, name, total, true, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  Sandwich get sandwich => puzzle;

  toString() {
    var sortedCells = cells;
    var text = '$name $total:${sortedCells.cellsString()}';
    return text;
  }

  @override
  List<List<int>>? regionCombinations() {
    var combinations = nextRegionCombinations(
      0,
      0,
      <int>[],
      <String, List<int>>{},
      remainingNoTotal,
      validNoTotal,
      true, // limited
      validSandwichRegionValues,
    );
    return combinations;
  }

  int validSandwichRegionValues(List<int> values, Cells valueCells) {
    return validSandwichValues(values, valueCells, this.total);
  }

  static int validSandwichValues(
      List<int> values, Cells valueCells, int total) {
    var inSandwich = false;
    var innieTotal = 0;
    var priorInnie = 0;
    var outieTotal = 0;

    for (var value in values) {
      if (value == 1 || value == 9) {
        inSandwich = !inSandwich;
      } else {
        if (inSandwich) {
          priorInnie = innieTotal;
          innieTotal += value;
        } else
          outieTotal += value;
      }
    }
    if (innieTotal > total && priorInnie == total)
      return 1; // continue processing higher values to get 9
    if (innieTotal > total) return -1; // break processing higher values
    if (outieTotal > 45 - 10 - total)
      return 1; // continue processing higher values to get 9
    if (innieTotal > 0 && !inSandwich && innieTotal < total)
      return 1; // continue processing higher values
    return 0;
  }

  static int validSandwichGroupValues(
      List<int> values, Cells valueCells, Cells cells, Puzzle puzzle,
      [List<Region>? regions]) {
    var sandwich = puzzle as Sandwich;

    // Check sandwich for cells in order
    var doneRegions = <SandwichRegion>[];
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      var cell = valueCells[valueIndex];
      var value = values[valueIndex];
      // Check sandwich sequence
      for (var sandwichRegion in sandwich.getSandwichs(cell).where(
          (sandwichRegion) =>
              !doneRegions.contains(sandwichRegion) &&
              (regions == null || regions.contains(sandwichRegion)))) {
        var index = sandwichRegion.cells.indexOf(cell);
        assert(index != -1);
        var sandwichValues = List<int>.filled(sandwichRegion.cells.length, 0);
        sandwichValues[index] = value;
        if (index > 0) {
          // Check if prior cells in sandwich have values
          for (var priorValueIndex = valueIndex - 1;
              priorValueIndex >= 0;
              priorValueIndex--) {
            var priorCell = valueCells[priorValueIndex];
            var priorValue = values[priorValueIndex];
            var priorIndex = sandwichRegion.cells.indexOf(priorCell);
            if (priorIndex != -1) {
              // In sandwich
              sandwichValues[priorIndex] = priorValue;
            }
          }
        }
        // Do we have a run of cells?
        var runValues =
            sandwichValues.takeWhile((value) => value != 0).toList();
        if (runValues.length > 0) {
          var result = SandwichRegion.validSandwichValues(runValues,
              cells.take(runValues.length).toList(), sandwichRegion.total);
          if (result != 0) return result;
        }
        doneRegions.add(sandwichRegion);
      }
    }
    return 0;
  }
}
