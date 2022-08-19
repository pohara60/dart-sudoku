import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';

class KillerRegion extends Region<Killer> {
  late Killer killer;
  late int total;
  late bool virtual;
  late String source;
  int? colour;

  KillerRegion(Killer killer, String name, int this.total, List<Cell> cells,
      [bool this.virtual = false, bool nodups = true, String this.source = ''])
      : super(killer, name, nodups, cells) {
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
    var text = '$total$source${nodups ? '' : 'd'}:';
    // var cellText = sortedCells.map((cageCell) => cageCell.name).join(',');
    var cellText2 = '';
    var currentRow = -1, currentCol = -1;
    var lastRow = -1, lastCol = -1;
    var firstRow = -1, firstCol = -1;
    String currentText() {
      var text = '';
      if (currentRow != -1) {
        text +=
            'R${currentRow}C${firstCol == lastCol ? firstCol : firstCol.toString() + '-' + lastCol.toString()}';
      } else if (currentCol != -1) {
        text +=
            'R${firstRow == lastRow ? firstRow : firstRow.toString() + '-' + lastRow.toString()}C$currentCol';
      }
      return text;
    }

    for (final cell in sortedCells) {
      if (cell.row == currentRow) {
        if (cell.col == lastCol + 1) {
          lastCol = cell.col;
          currentCol = -1;
        } else {
          cellText2 += (cellText2 != '' ? ',' : '') + currentText();
          currentCol = cell.col;
          firstRow = lastRow = cell.row;
          firstCol = lastCol = cell.col;
        }
      } else if (cell.col == currentCol) {
        if (cell.row == lastRow + 1) {
          lastRow = cell.row;
          currentRow = -1;
        } else {
          cellText2 += (cellText2 != '' ? ',' : '') + currentText();
          currentRow = cell.row;
          firstRow = lastRow = cell.row;
          firstCol = lastCol = cell.col;
        }
      } else {
        cellText2 += (cellText2 != '' ? ',' : '') + currentText();
        currentRow = cell.row;
        currentCol = cell.col;
        firstCol = lastCol = cell.col;
        firstRow = lastRow = cell.row;
      }
    }
    cellText2 += (cellText2 != '' ? ',' : '') + currentText();

    text += cellText2;
    return text;
  }

  bool equals(KillerRegion other) {
    // Equal if cells are same
    if (this.cells.length == other.cells.length &&
        this.cells.every(
            (cell) => other.cells.any((otherCell) => otherCell == cell))) {
      return true;
    }
    return false;
  }

  /// Compute the set of values in the possible combinations for a cage
  List<List<int>> cageCombinations() {
    var combinations = this.regionCombinations(this.total);
    return combinations;
  }
}
