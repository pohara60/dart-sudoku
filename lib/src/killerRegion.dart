import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/killer.dart';
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
}
