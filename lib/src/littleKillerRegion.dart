import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/littleKiller.dart';
import 'package:sudoku/src/region.dart';

class LittleKillerRegion extends Region<LittleKiller> {
  late final String direction;

  LittleKillerRegion(LittleKiller littleKiller, String name, int total,
      String direction, Cells cells,
      {bool nodups = false})
      : super(littleKiller, name, total, nodups, cells) {
    this.direction = direction;
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  LittleKiller get littleKiller => puzzle;

  toString() {
    var sortedCells = cells;
    var text = '$name:${sortedCells.cellsString()}';
    return text;
  }

  @override
  List<List<int>>? regionCombinations() {
    var combinations = nextRegionCombinations(
      0,
      this.total,
      <int>[],
      <String, List<int>>{},
      remainingExactTotal,
      validExactTotal,
      true, // limited
    );
    return combinations;
  }
}

class LittleKillerRegionGroup extends RegionGroup {
  LittleKillerRegionGroup(LittleKiller puzzle, String name, String nonet,
      bool nodups, List<Region> regions, Cells cells)
      : super(puzzle, name, nonet, nodups, regions, cells);

  LittleKiller get littleKiller => puzzle;

  @override
  List<List<int>>? regionGroupCombinations(String explanation) {
    //print('$explanation not yet implemented!');
    //return null;
    // Get combinations while validating the (partial) littleKillers in the group
    // Get combinations for littleKiller lines
    // Limited to maximum
    var littleKillerCells = this.cells;
    var combinationCount = Limiter(COMBINATION_LIMIT);
    var iterationCount = Limiter(ITERATION_LIMIT);
    // var stopwatch = Stopwatch();
    // stopwatch.start();
    try {
      var littleKillerCombinations = cellCombinations(
        littleKillerCells,
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
        validLittleKillerRegionGroupValues,
      );
      // stopwatch.stop();
      // print(
      //     'combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      // Get minimum total of littleKillerCombinations
      return littleKillerCombinations;
    } catch (e) {
      // stopwatch.stop();
      // print(
      //     'exception combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      return null;
    }
  }

  int validLittleKillerRegionGroupValues(List<int> values, Cells valueCells) {
    var cells = this.cells;
    return validLittleKillerGroupValues(values, valueCells, cells, puzzle);
  }

  static int validLittleKillerGroupValues(
      List<int> values, Cells valueCells, Cells cells, Puzzle puzzle,
      [List<Region>? regions]) {
    // Check littleKiller maximums first as they shortcut processing
    var littleKiller = puzzle as LittleKiller;
    var valueIndex = values.length - 1;
    var cell = valueCells[valueIndex];
    var value = values[valueIndex];
    for (var littleKiller in littleKiller.getLittleKillers(cell)) {
      if ((regions == null || regions.contains(littleKiller))) {
        var killerValues = [value];
        for (var priorValueIndex = valueIndex - 1;
            priorValueIndex >= 0;
            priorValueIndex--) {
          var priorCell = valueCells[priorValueIndex];
          var priorValue = values[priorValueIndex];
          var priorIndex = littleKiller.cells.indexOf(priorCell);
          if (priorIndex != -1) {
            // In killer
            killerValues.add(priorValue);
          }
        }
        // Check unique
        if (littleKiller.nodups) {
          if (Set.from(killerValues).length != killerValues.length)
            return 1; // continue higher values
        }
        // Check total
        var sum = killerValues.fold<int>(0, (sum, value) => sum + value);
        if (sum > littleKiller.total) return -1; // break higher values
        if (sum < littleKiller.total &&
            killerValues.length == littleKiller.cells.length)
          return 1; // continue higher values
      }
    }

    return 0;
  }
}
