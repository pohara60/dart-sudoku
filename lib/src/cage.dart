import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/killer.dart';
import 'package:sudoku/src/possible.dart';

class CageCell {
  late final Cell cell; // The cell
  late final Cage cage; // Primary cage
  late final List<Cage> cages; // All cages including virtual
  CageCell();
  factory CageCell.forCell(cell, cage, Killer killer) {
    late CageCell cageCell;
    if (killer.cellCageCell[cell] == null) {
      cageCell = CageCell();
      cageCell.cell = cell;
      cageCell.cage = cage;
      cageCell.cages = <Cage>[];
      killer.cellCage[cell] = cage;
      killer.cellCageCell[cell] = cageCell;
    } else {
      cageCell = killer.cellCageCell[cell]!;
    }
    cageCell.cages.add(cage);
    cage.cageCells.add(cageCell);
    return cageCell;
  }
  int get row => cell.row;
  int get col => cell.col;
  String get name => cell.name;
  Possible get possible => cell.possible;
  int compareTo(CageCell other) {
    return this.cell.compareTo(other.cell);
  }

  String toString() {
    var text = cell.toString();
    return text;
  }
}

class Cage {
  late Killer killer;
  int total;
  late List<CageCell> cageCells;
  bool virtual;
  bool nodups;
  String source;
  late bool zombie;
  int? colour;

  void _validate() {
    this
        .cageCells
        .sort((cageCell1, cellCage2) => cageCell1.compareTo(cellCage2));

    // Check for duplicate virtual cage - look at cages for first cell
    if (virtual) {
      var cages = this.cageCells[0].cages;
      for (final cage in cages) {
        if (cage.total != this.total) continue;
        if (cage.cageCells.length != this.cageCells.length) continue;
        var difference =
            cage.cageCells.where((x) => !this.cageCells.contains(x));
        if (difference.length > 0) continue;
        // Duplicate cage will be a zombie
        this.zombie = true;
        return;
      }
    }

    // Set cage for cells
    this.zombie = false;
    // this.cells.forEach((cell) {
    //   if (!virtual) {
    //     cell.cage = this;
    //   }
    //   cell.cages.add(this);
    // });
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

  Cage(this.killer, this.total, List<List<int>> locations,
      [this.virtual = false, this.nodups = true, this.source = '']) {
    this.cageCells = [];

    // Get cage cells
    locations.forEach((element) {
      var cell = killer.grid.getCell(element[0], element[1]);
      CageCell.forCell(cell, this, killer);
    });

    this._validate();
  }

  Cage.fromCageCells(this.killer, this.total, List<CageCell> cageCells,
      [this.virtual = true, this.nodups = true, this.source = '']) {
    this.cageCells = List<CageCell>.from(cageCells);
    cageCells.forEach((cageCell) {
      cageCell.cages.add(this);
    });
    this._validate();
  }

  toString() {
    var sortedCells = cageCells;
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

  bool equals(Cage other) {
    // Equal if cells are same
    if (this.cageCells.length == other.cageCells.length &&
        this.cageCells.every((cageCell) => other.cageCells
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
  List<List<int>> findCageCombinations(int index, int total,
      List<int> setValues, Map<String, List<int>> axisValues) {
    var cageCells = this.cageCells;
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
            var label = cageCell.cell.getAxisName(axis);
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
              var label = cageCell.cell.getAxisName(axis);
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

List<CageCell> intersectionCageCells(List<CageCell> l1, List<CageCell> l2) {
  var result = l1.where((cageCell) => l2.contains(cageCell)).toList();
  return result;
}

List<CageCell> remainderCageCells(List<CageCell> l1, List<CageCell> l2) {
  var result = l1.where((cageCell) => !l2.contains(cageCell)).toList();
  return result;
}

int fixedTotalCageCells(List<CageCell> cageCells) {
  if (cageCells.length == 0) return 0;
  if (cageCells.length == 1) {
    var cell = cageCells[0].cell;
    if (cell.isSet) return cell.value!;
    return 0;
  }
  int total = 0;
  var cells = cageCells.map((cageCell) => cageCell.cell).toList();
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
