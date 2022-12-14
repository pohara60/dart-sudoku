import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/line.dart';
import 'package:sudoku/src/region.dart';

abstract class LineRegion extends Region<Line> {
  late Line line;

  LineRegion.new(Line line, String name, Cells cells,
      {nodups = true, total = 5})
      : super(line, name, total, nodups, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

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
      false, // Unlimited combinations
      validLineRegionValues, // Check Line values
    );
    return combinations;
  }

  int validLineRegionValues(List<int> values, Cells valueCells) {
    return validLineValues(values, valueCells, this.cells);
  }

  int validLineValues(List<int> values, Cells valueCells, Cells cells) {
    throw UnimplementedError();
  }

  int validLineGroupValues(List<int> values, Cells valueCells, Cells cells,
      puzzle, List<Region>? regions) {
    var line = puzzle as Line;

    // Check line for cells in order
    var doneRegions = <LineRegion>[];
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      var cell = valueCells[valueIndex];
      var value = values[valueIndex];
      // Check line(s)
      for (var lineRegion in line.getLines(cell).where((lineRegion) =>
          !doneRegions.contains(lineRegion) &&
          (regions == null || regions.contains(lineRegion)))) {
        var index = lineRegion.cells.indexOf(cell);
        assert(index != -1);
        var lineValues = <int>[];
        Cells lineCells = <Cell>[];
        lineValues.add(value);
        lineCells.add(cell);
        // Check if other cells in line have values
        for (var priorValueIndex = valueIndex - 1;
            priorValueIndex >= 0;
            priorValueIndex--) {
          var priorCell = valueCells[priorValueIndex];
          var priorValue = values[priorValueIndex];
          var priorIndex = lineRegion.cells.indexOf(priorCell);
          if (priorIndex != -1) {
            // In line
            lineValues.add(priorValue);
            lineCells.add(priorCell);
          }
        }

        var result = lineRegion.validLineRegionValues(lineValues, lineCells);
        if (result != 0) return result;

        doneRegions.add(lineRegion);
      }
    }
    return 0;
  }
}
