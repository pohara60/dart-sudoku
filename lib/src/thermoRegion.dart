import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/thermo.dart';
import 'package:sudoku/src/region.dart';

class ThermoRegion extends Region<Thermo> {
  ThermoRegion(Thermo thermo, String name, Cells cells)
      : super(thermo, name, 0, true, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  Thermo get thermo => puzzle;

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
      remainingNoTotal,
      validNoTotal,
      false, // unlimited
      validThermoValues,
    );
    return combinations;
  }

  int validThermoValues(List<int> values) {
    // Check for thermo from prior cell
    var value = values[values.length - 1];
    if (values.length > 1) {
      var priorValue = values[values.length - 2];
      if (value <= priorValue) return 1; // continue processing higher values
    }
    // Check thermo maximum
    var max = 9 - (this.cells.length - values.length);
    if (max < value) return -1; // break processing higher values
    return 0;
  }
}

class ThermoRegionGroup extends RegionGroup {
  ThermoRegionGroup(Thermo puzzle, String name, String nonet, bool nodups,
      List<Region> regions, Cells cells)
      : super(puzzle, name, nonet, nodups, regions, cells);

  Thermo get thermo => puzzle;

  @override
  List<List<int>>? regionGroupCombinations(String explanation) {
    //print('$explanation not yet implemented!');
    //return null;
    // Get combinations while validating the (partial) thermos in the group
    // Get combinations for thermo lines
    // Limited to maximum
    var thermoCells = this.cells;
    var combinationCount = Limiter(COMBINATION_LIMIT);
    var iterationCount = Limiter(ITERATION_LIMIT);
    // var stopwatch = Stopwatch();
    // stopwatch.start();
    try {
      var thermoCombinations = cellCombinations(
        thermoCells,
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
        validThermoRegionGroupValues,
      );
      // stopwatch.stop();
      // print(
      //     'combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      // Get minimum total of thermoCombinations
      return thermoCombinations;
    } catch (e) {
      // stopwatch.stop();
      // print(
      //     'exception combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      return null;
    }
  }

  int validThermoRegionGroupValues(List<int> values) {
    var cells = this.cells;
    return validThermoGroupValues(values, cells, puzzle);
  }

  static int validThermoGroupValues(
      List<int> values, Cells cells, Puzzle puzzle) {
    // Check thermo maximums first as they shortcut processing
    var thermo = puzzle as Thermo;
    var cell = cells[values.length - 1];
    var value = values[values.length - 1];
    for (var thermo in thermo.getThermos(cell)) {
      var index = thermo.cells.indexOf(cell);
      var max = 9 - (thermo.cells.length - index - 1);
      if (max < value) return -1; // break processing higher values
    }

    // Check thermo for each cell that has a value
    // Recheck earlier cells in case a later cell is the prior cell
    bool latest = true;
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      cell = cells[valueIndex];
      value = values[valueIndex];
      // Check thermo sequence
      for (var thermo in thermo.getThermos(cell)) {
        var index = thermo.cells.indexOf(cell);
        assert(index != -1);
        if (index > 0) {
          var priorCell = thermo.cells[index - 1];
          var priorValueIndex = cells.indexOf(priorCell);
          if (priorValueIndex < values.length) {
            // Check for thermo from prior cell
            var priorValue = values[priorValueIndex];
            if (value <= priorValue) if (latest)
              return 1; // continue processing higher values
            else
              return -1; // priorValue set later is too high, so break
          }
        }
      }
      latest = false;
    }
    return 0;
  }
}
