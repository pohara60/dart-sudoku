import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/possible.dart';

class CageCell {
  final Cell cell; // The cell
  late Cage cage; // Primary cage
  late List<Cage> cages; // All cages including virtual
  CageCell(this.cell) {
    cages = <Cage>[];
  }
  int get row => cell.row;
  int get col => cell.col;
  String get name => cell.name;
  Possible get possible => cell.possible;
  int compareTo(CageCell other) {
    return this.cell.compareTo(other.cell);
  }
}

class Cage {
  late Killer killer;
  int total;
  late List<CageCell> cells;
  bool virtual;
  bool nodups;
  String source;
  late bool zombie;
  int? colour;

  Cage(this.killer, this.total, List<List<int>> locations,
      [this.virtual = false, this.nodups = true, this.source = '']) {
    this.cells = [];

    // Get cage cells
    locations.forEach((element) {
      var cell = killer.grid.getCell(element[0], element[1]);
      this.cells.add(CageCell(cell));
    });
    this.cells.sort((cageCell1, cellCage2) => cageCell1.compareTo(cellCage2));

    // Check for duplicate virtual cage - look at cages for first cell
    if (virtual) {
      var cages = this.cells[0].cages;
      for (final cage in cages) {
        if (cage.total != this.total) continue;
        if (cage.cells.length != this.cells.length) continue;
        var difference = cage.cells.where((x) => !this.cells.contains(x));
        if (difference.length > 0) continue;
        // Duplicate cage will be a zombie
        this.zombie = true;
        return;
      }
    }

    // Set cage for cells
    this.zombie = false;
    this.cells.forEach((cell) {
      if (!virtual) {
        cell.cage = this;
      }
      cell.cages.add(this);
    });
    // Add non-virtual cage to the grid display
    // if (!virtual) {
    //     if (grid.grid.cages == null) {
    //         grid.grid.cages = [this];
    //     } else {
    //         grid.grid.cages.add(this);
    //     }
    // } else {
    //     if (sudoku.debug) console.log('Add virtual cage: ' + this);
    // }
  }

  toString() {
    var sortedCells = cells;
    var text =
        '$total [${this.cells.length}] ${virtual ? 'v' : 'r'} ${nodups ? 'u' : 'd'}:';
    var cellText = sortedCells.map((cageCell) => cageCell.name).join(',');
    var cellText2 = '';
    var currentRow = -1, currentCol = -1;
    var lastRow = -1, lastCol = -1;
    var firstRow = -1, firstCol = -1;
    String currentText() {
      var text = '';
      if (currentRow != -1) {
        text +=
            '[$currentRow,${firstCol == lastCol ? firstCol : firstCol.toString() + '-' + lastCol.toString()}]';
      } else if (currentCol != -1) {
        text +=
            '[${firstRow == lastRow ? firstRow : firstRow.toString() + '-' + lastRow.toString()},$currentCol]';
      }
      return text;
    }

    for (final cell in sortedCells) {
      if (cell.row == currentRow) {
        if (cell.col == lastCol + 1) {
          lastCol = cell.col;
          currentCol = -1;
        } else {
          cellText2 += currentText();
          currentCol = cell.col;
          firstRow = lastRow = cell.row;
          firstCol = lastCol = cell.col;
        }
      } else if (cell.col == currentCol) {
        if (cell.row == lastRow + 1) {
          lastRow = cell.row;
          currentRow = -1;
        } else {
          cellText2 += currentText();
          currentRow = cell.row;
          firstRow = lastRow = cell.row;
          firstCol = lastCol = cell.col;
        }
      } else {
        cellText2 += currentText();
        currentRow = cell.row;
        currentCol = cell.col;
        firstCol = lastCol = cell.col;
        firstRow = lastRow = cell.row;
      }
    }
    cellText2 += currentText();

    text += cellText2;
    if (this.source != '') {
      text += ' ($source)';
    }
    return text;
  }

  bool equals(Cage other) {
    // Equal if cells are same
    if (this.cells.length == other.cells.length &&
        this.cells.every((cageCell) => other.cells
            .any((otherCageCell) => otherCageCell.cell == cageCell.cell))) {
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
  List<List<int>> findCageCombinations(
      int index, int total, List<int> setValues) {
    var cells = this.cells;
    var newCombinations = <List<int>>[];
    final cell = cells[index];
    for (var value = 1; value < 10; value++) {
      if (cell.possible[value] && !(this.nodups && setValues.contains(value))) {
        if (index + 1 == cells.length) {
          if (total == value) {
            setValues.add(value);
            newCombinations.add(setValues);
            break;
          }
        } else if (total > value) {
          // find combinations for reduced total in remaining cells
          var combinations = findCageCombinations(
              index + 1, total - value, [...setValues, value]);
          newCombinations.addAll(combinations);
        }
      }
    }
    return newCombinations;
  }
}
