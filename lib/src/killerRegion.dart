import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/region.dart';

class KillerRegion extends Region<Killer> {
  late Killer killer;
  late bool virtual;
  late String source;
  int? colour;

  KillerRegion(Killer killer, String name, int total, Cells cells,
      [bool this.virtual = false, bool nodups = true, String this.source = ''])
      : super(killer, name, total, nodups, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  factory KillerRegion.locations(
      Killer killer, String name, int total, List<List<int>> locations,
      [bool virtual = false, bool nodups = true, String source = '']) {
    // Get cage cells
    var cells = <Cell>[];
    locations.forEach((element) {
      var cell = killer.sudoku.getCell(element[0], element[1]);
      cells.add(cell);
    });

    var region =
        KillerRegion(killer, name, total, cells, virtual, nodups, source);
    return region;
  }

  toString() {
    var sortedCells = cells;
    var text =
        '$name $total$source${nodups ? '' : 'd'}:${sortedCells.cellsString()}';
    return text;
  }

  static int validKillerGroupValues(
      List<int> values, Cells valueCells, Cells cells, Puzzle puzzle,
      [List<Region>? regions]) {
    var killer = puzzle as Killer;

    // Check killer for cells
    var doneRegions = <KillerRegion>[];
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      var cell = valueCells[valueIndex];
      var value = values[valueIndex];
      // Check killer
      var killerRegion = killer.getCage(cell);
      if (killerRegion != null &&
          !doneRegions.contains(killerRegion) &&
          (regions == null || regions.contains(killerRegion))) {
        var killerValues = [value];
        for (var priorValueIndex = valueIndex - 1;
            priorValueIndex >= 0;
            priorValueIndex--) {
          var priorCell = valueCells[priorValueIndex];
          var priorValue = values[priorValueIndex];
          var priorIndex = killerRegion.cells.indexOf(priorCell);
          if (priorIndex != -1) {
            // In killer
            killerValues.add(priorValue);
          }
        }
        // Check unique
        if (killerRegion.nodups) {
          if (Set.from(killerValues).length != killerValues.length)
            return 1; // continue higher values
        }
        // Check total
        if (killerRegion.total != 0) {
          var sum = killerValues.fold<int>(0, (sum, value) => sum + value);
          if (sum > killerRegion.total) return -1; // break higher values
          if (sum < killerRegion.total &&
              killerValues.length == killerRegion.cells.length)
            return 1; // continue higher values
        }
        doneRegions.add(killerRegion);
      }
    }
    return 0;
  }
}
