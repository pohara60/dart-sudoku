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

  /**
     * Compute the set of values in the possible combinations for a cage
     * @param {number} index - index of next cell in cage to process
     * @param {number} total - total value for remaining cells in cage
     * @param {Array} setValues - the set of values in the combinations so far
     * @returns {Array} the set of values in the combinations
     */
  List<List<int>> findCageCombinations(int index, int total,
      List<int> setValues, Map<String, List<int>> axisValues) {
    var cageCells = this.cells;
    var newCombinations = <List<int>>[];
    final cageCell = cageCells[index];
    valueLoop:
    for (var value = 1; value < 10; value++) {
      if (cageCell.possible[value]) {
        // Check if no duplicates allowed
        if (this.nodups) {
          if (setValues.contains(value)) continue valueLoop;
        } else {
          // Check if Row, Column or Box have duplicate for this cage
          for (var axis in ['R', 'C', 'B']) {
            var label = cageCell.getAxisName(axis);
            if (axisValues.containsKey(label) &&
                axisValues[label]!.contains(value)) continue valueLoop;
          }
        }

        if (index + 1 == cageCells.length) {
          if (total == value) {
            setValues.add(value);
            newCombinations.add(setValues);
            break;
          }
        } else if (total > value) {
          // Record values for Row, Column or Box for this cage
          var newAxisValues = axisValues;
          if (!this.nodups) {
            newAxisValues = Map<String, List<int>>.from(axisValues);
            for (var label in newAxisValues.keys) {
              newAxisValues[label] = List.from(newAxisValues[label]!);
            }
            for (var axis in ['R', 'C', 'B']) {
              var label = cageCell.getAxisName(axis);
              if (!newAxisValues.containsKey(label))
                newAxisValues[label] = <int>[];
              newAxisValues[label]!.add(value);
            }
          }
          // find combinations for reduced total in remaining cells
          var combinations = findCageCombinations(
              index + 1, total - value, [...setValues, value], newAxisValues);
          newCombinations.addAll(combinations);
        }
      }
    }
    return newCombinations;
  }
}

List<Cell> intersectionCells(List<Cell> l1, List<Cell> l2) {
  var result = l1.where((cell) => l2.contains(cell)).toList();
  return result;
}

List<Cell> remainderCells(List<Cell> l1, List<Cell> l2) {
  var result = l1.where((cell) => !l2.contains(cell)).toList();
  return result;
}

int fixedTotalCells(List<Cell> cells) {
  if (cells.length == 0) return 0;
  if (cells.length == 1) {
    var cell = cells[0];
    if (cell.isSet) return cell.value!;
    return 0;
  }
  int total = 0;
  var nodups = cellsInNonet(cells);
  if (nodups) {
    // Total is fixed if number of possible values is same as number of cells
    var unionPossible = unionCellsPossible(cells);
    if (unionPossible.count != cells.length) return 0;
    for (var value = 1; value < 10; value++) {
      if (unionPossible[value]) total += value;
    }
  } else {
    // Total is fixed if all cells are set
    if (cells.any((element) => !element.isSet)) return 0;
    total = cells.fold<int>(0, (total, cell) => total + cell.value!);
  }
  return total;
}
