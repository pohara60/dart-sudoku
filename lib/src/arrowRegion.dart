import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/arrow.dart';
import 'package:sudoku/src/region.dart';

class ArrowRegion extends Region<Arrow> {
  late Arrow arrow;

  ArrowRegion(Arrow arrow, String name, List<Cell> cells, {nodups = true})
      : super(arrow, name, 0, nodups, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  toString() {
    var sortedCells = cells;
    var text = '$name:${cellsString(sortedCells)}';
    return text;
  }

  @override
  List<List<int>> regionCombinations() {
    var setValues = <int>[];
    var axisValues = <String, List<int>>{};
    var combinations = nextRegionCombinations(
      0,
      0,
      setValues,
      axisValues,
      remainingArrowTotal,
      validArrowTotal,
    );
    return combinations;
  }
}

class ArrowRegionGroup extends RegionGroup {
  ArrowRegionGroup(Arrow puzzle, String name, String nonet, bool nodups,
      List<Region> regions, List<Cell> cells)
      : super(puzzle, name, nonet, nodups, regions, cells);

  int get minimum {
    return 0;
  }

  @override
  List<List<int>> regionGroupCombinations(String explanation) {
    // Get maximum value of arrow totals
    var totalCells =
        this.regions.expand((region) => [region.cells[0]]).toList();
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
    );
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
    );
    // Get minimum total of arrowCombinations
    var arrowMin =
        arrowCombinations.fold<int>(arrowCells.length * 9, (min, combination) {
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
  }
}
