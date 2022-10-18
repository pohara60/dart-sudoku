import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/renban.dart';
import 'package:sudoku/src/region.dart';

class RenbanRegion extends Region<Renban> {
  late Renban renban;
  int difference;

  RenbanRegion(Renban renban, String name, Cells cells,
      {nodups = true, this.difference = 5})
      : super(renban, name, 0, nodups, cells) {
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
      validRenbanRegionValues, // Check Renban values
    );
    return combinations;
  }

  int validRenbanRegionValues(List<int> values) {
    return validRenbanValues(values, this.cells);
  }

  static int validRenbanValues(List<int> values, Cells cells) {
    // Check for renban from prior cells
    if (values.length > 1) {
      var minValue = 10;
      var maxValue = 0;
      for (var value in values) {
        if (value < minValue) minValue = value;
        if (value > maxValue) maxValue = value;
      }
      if (maxValue - minValue >= cells.length) return 1; // continue
    }
    return 0;
  }

  static int validRenbanGroupValues(
      List<int> values, Cells cells, puzzle, List<Region>? regions) {
    var renban = puzzle as Renban;

    // Check renban for cells in order
    var doneRegions = <RenbanRegion>[];
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      var cell = cells[valueIndex];
      var value = values[valueIndex];
      // Check renban(s)
      for (var renbanRegion in renban.getRenbans(cell).where((renbanRegion) =>
          !doneRegions.contains(renbanRegion) &&
          (regions == null || regions.contains(renbanRegion)))) {
        var index = renbanRegion.cells.indexOf(cell);
        assert(index != -1);
        var renbanValues = <int>[];
        renbanValues.add(value);
        // Check if other cells in renban have values
        for (var priorValueIndex = valueIndex - 1;
            priorValueIndex >= 0;
            priorValueIndex--) {
          var priorCell = cells[priorValueIndex];
          var priorValue = values[priorValueIndex];
          var priorIndex = renbanRegion.cells.indexOf(priorCell);
          if (priorIndex != -1) {
            // In renban
            renbanValues.add(priorValue);
          }
        }

        var result = validRenbanValues(renbanValues, renbanRegion.cells);
        if (result != 0) return result;

        doneRegions.add(renbanRegion);
      }
    }
    return 0;
  }
}
