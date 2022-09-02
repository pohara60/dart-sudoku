import 'package:sudoku/src/cell.dart';

abstract class Region<Puzzle> {
  Puzzle puzzle;
  List<Cell> cells;
  String name;
  int total;
  bool nodups;
  Map<int, Set<Cell>> mandatory;
  Region(Puzzle this.puzzle, String this.name, int this.total, bool this.nodups,
      List<Cell> this.cells)
      : mandatory = Map<int, Set<Cell>>();
  String toString();

  String cellsString(List<Cell> sortedCells) {
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
    return cellText2;
  }

  bool equals(Region other) {
    // Equal if cells are same
    if (this.cells.length == other.cells.length &&
        this.cells.every(
            (cell) => other.cells.any((otherCell) => otherCell == cell))) {
      return true;
    }
    return false;
  }

  /// Compute the set of values in the possible combinations for a region
  List<List<int>> regionCombinations() {
    var setValues = <int>[];
    var axisValues = <String, List<int>>{};
    var combinations = nextRegionCombinations(
      0,
      total,
      setValues,
      axisValues,
      remainingOptionalTotal,
      validOptionalTotal,
    );
    return combinations;
  }

  /// Compute the set of values in the possible combinations for a region
  /// Region may or may not have a total
  /// index - index of next cell in region to process
  /// total - total value for remaining cells in region
  /// setValues - the set of values in the combinations so far
  /// remainingTotal - function to update total for each value
  /// returns the set of values in the combinations
  List<List<int>> nextRegionCombinations(
    int index,
    int total,
    List<int> setValues,
    Map<String, List<int>>? axisValues,
    int remainingTotal(int total, int value, int index),
    bool validTotal(int total, int value),
  ) {
    return cellCombinations(this.cells, this.nodups, this.mandatory, index,
        total, setValues, axisValues, remainingTotal, validTotal);
  }
}

abstract class RegionGroup<Puzzle> extends Region<Puzzle> {
  List<Cell> outies;
  String nonet;
  List<Region> regions;
  RegionGroup(Puzzle puzzle, String name, String this.nonet, nodups,
      List<Region> this.regions, List<Cell> cells, List<Cell> this.outies)
      : super(puzzle, name, 0, nodups, cells);

  String toString() {
    var regions = this.regions.map<String>((r) => r.name);
    var text =
        '$name $nonet,$regions:${cellsString(cells)}:${cellsString(outies)}';
    return text;
  }

  int get minimum {
    return 0;
  }

  List<List<int>> regionGroupCombinations(String explanation) {
    var setValues = <int>[];
    var axisValues = <String, List<int>>{};
    var combinations = nextRegionCombinations(
      0,
      this.total,
      setValues,
      axisValues,
      remainingOptionalTotal,
      validOptionalTotal,
    );
    return combinations;
  }
}

/// Callback functions for cellCombinations
bool validNoTotal(_, value) => true;
bool validExactTotal(total, value) => total == value;
bool validOptionalTotal(total, value) => total == 0 || total == value;
bool validMaxTotal(maximum, value) => maximum >= value;
bool validArrowTotal(total, value) => total == value;
int remainingNoTotal(_, value, index) => 0;
int remainingExactTotal(total, value, index) => total - value;
int remainingOptionalTotal(total, value, index) =>
    total == 0 ? 0 : total - value;
int remainingMaxTotal(maximum, value, index) => maximum - value;
int remainingArrowTotal(total, value, index) =>
    index == 0 ? value : total - value;

/// Compute the set of values in the possible combinations for cells
/// cells - the cells
/// nodups - no duplicates
/// mandatory - mandatory values in cells
/// index - index of next cell in region to process
/// total - total value for remaining cells in region
/// setValues - the set of values in the combinations so far
/// remainingTotal - function to update total for each value
/// returns the set of values in the combinations
List<List<int>> cellCombinations(
  List<Cell> cells,
  bool nodups,
  Map<int, Set<Cell>>? mandatory,
  int index,
  int total,
  List<int> setValues,
  Map<String, List<int>>? axisValues,
  int remainingTotal(int total, int value, int index),
  bool validTotal(int total, int value),
) {
  var regionCells = cells;
  assert(nodups || axisValues != null);
  var newCombinations = <List<int>>[];
  final regionCell = regionCells[index];
  valueLoop:
  for (var value = 1; value < 10; value++) {
    if (regionCell.possible[value]) {
      // Check if no duplicates allowed
      if (nodups) {
        if (setValues.contains(value)) continue valueLoop;
      } else {
        // Check if Row, Column or Box have duplicate for this region
        for (var axis in ['R', 'C', 'B']) {
          var label = regionCell.getAxisName(axis);
          if (axisValues!.containsKey(label) &&
              axisValues[label]!.contains(value)) continue valueLoop;
        }
      }

      if (index + 1 == regionCells.length) {
        // Check region total, if any
        var valid = validTotal(total, value);
        if (valid) {
          // Check region mandatory, if any
          var combination = [...setValues, value];
          if (mandatory == null ||
              mandatory.entries.every((entry) {
                var index = combination.indexOf(entry.key);
                return (index != -1 && entry.value.contains(cells[index]));
              })) {
            newCombinations.add(combination);
            if (total > 0 && validTotal != validMaxTotal) {
              // Exact value required, so can break
              break;
            } else {
              // Loop to get more combinations
              continue valueLoop;
            }
          }
        }
      } else if (total > value || total == 0) {
        // Record values for Row, Column or Box for this region
        var newAxisValues = axisValues;
        if (!nodups) {
          newAxisValues = Map<String, List<int>>.from(axisValues!);
          for (var label in newAxisValues.keys) {
            newAxisValues[label] = List.from(newAxisValues[label]!);
          }
          for (var axis in ['R', 'C', 'B']) {
            var label = regionCell.getAxisName(axis);
            if (!newAxisValues.containsKey(label))
              newAxisValues[label] = <int>[];
            newAxisValues[label]!.add(value);
          }
        }
        // find combinations for reduced total in remaining cells
        var remaining = remainingTotal(total, value, index);
        var combinations = cellCombinations(
            cells,
            nodups,
            mandatory,
            index + 1,
            remaining,
            [...setValues, value],
            newAxisValues,
            remainingTotal,
            validTotal);
        newCombinations.addAll(combinations);
      }
    }
  }
  return newCombinations;
}
