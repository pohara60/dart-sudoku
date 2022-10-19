import 'package:collection/collection.dart';
import 'package:sudoku/src/renbanRegion.dart';
import 'arrowRegion.dart';
import 'killerRegion.dart';
import 'sandwichRegion.dart';
import 'sudoku.dart';
import 'thermoRegion.dart';
import 'cell.dart';
import 'dominoRegion.dart';
import 'puzzle.dart';
import 'region.dart';

class MixedRegionGroup extends RegionGroup {
  MixedRegionGroup(Puzzle puzzle, String name, String nonet, bool nodups,
      List<Region> regions, Cells cells)
      : super(puzzle, name, nonet, nodups, regions, cells);

  Sudoku get sudoku => puzzle.sudoku;

  @override
  List<List<int>>? regionGroupCombinations(String explanation) {
    // Get combinations while validating the (partial) regions in the group
    // Limited to maximum
    var mixedCells = this.cells;
    var combinationCount = Limiter(COMBINATION_LIMIT);
    var iterationCount = Limiter(ITERATION_LIMIT);
    var stopwatch = Stopwatch();
    stopwatch.start();
    try {
      var mixedCombinations = cellCombinations(
        mixedCells,
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
        validMixedGroupValues,
      );
      stopwatch.stop();
      sudoku.debugPrint(
          'combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      return mixedCombinations;
    } catch (e) {
      sudoku.debugPrint(
          'exception combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      return null;
    }
  }

  int validMixedGroupValues(List<int> values) {
    var cells = this.cells;
    var cell = cells[values.length - 1];
    var regions = sudoku
        .getRegions(cell)
        .where((region) => this.regions.contains(region))
        .toList();
    var result = 0;

    var thermoRegion =
        regions.firstWhereOrNull((region) => region is ThermoRegion);
    if (thermoRegion != null) {
      result = ThermoRegionGroup.validThermoGroupValues(
          values, cells, thermoRegion.puzzle);
      if (result != 0) return result;
    }
    var dominoRegion =
        regions.firstWhereOrNull((region) => region is DominoRegion);
    if (dominoRegion != null) {
      result = DominoRegionGroup.validDominoGroupValues(
          values, cells, dominoRegion.puzzle);
      if (result != 0) return result;
    }
    var sandwichRegion =
        regions.firstWhereOrNull((region) => region is SandwichRegion);
    if (sandwichRegion != null) {
      result = SandwichRegion.validSandwichGroupValues(
          values, cells, sandwichRegion.puzzle, regions);
      if (result != 0) return result;
    }
    var killerRegion =
        regions.firstWhereOrNull((region) => region is KillerRegion);
    if (killerRegion != null) {
      result = KillerRegion.validKillerGroupValues(
          values, cells, killerRegion.puzzle, regions);
      if (result != 0) return result;
    }
    var arrowRegion =
        regions.firstWhereOrNull((region) => region is ArrowRegion);
    if (arrowRegion != null) {
      result = ArrowRegion.validArrowGroupValues(
          values, cells, arrowRegion.puzzle, regions);
      if (result != 0) return result;
    }
    var renbanRegion =
        regions.firstWhereOrNull((region) => region is RenbanRegion);
    if (renbanRegion != null) {
      result = RenbanRegion.validRenbanGroupValues(
          values, cells, renbanRegion.puzzle, regions);
      if (result != 0) return result;
    }
    return 0;
  }
}
