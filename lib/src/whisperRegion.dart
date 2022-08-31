import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/whisper.dart';
import 'package:sudoku/src/region.dart';

class WhisperRegion extends Region<Whisper> {
  late Whisper whisper;
  int difference;

  WhisperRegion(Whisper whisper, String name, List<Cell> cells,
      {nodups = true, this.difference = 5})
      : super(whisper, name, 0, nodups, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  toString() {
    var sortedCells = cells;
    var text = '$name:';
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

  @override
  List<List<int>> regionCombinations() {
    var setValues = <int>[];
    var axisValues = <String, List<int>>{};
    var combinations = _lineCombinations(0, setValues, axisValues);
    return combinations;
  }

  /// Compute the set of values in the possible combinations for a line
  /// index - index of next cell in region to process
  /// setValues - the set of values in the combinations so far
  /// returns the set of values in the combinations
  List<List<int>> _lineCombinations(
      int index, List<int> setValues, Map<String, List<int>> axisValues) {
    var regionCells = this.cells;
    var newCombinations = <List<int>>[];
    final regionCell = regionCells[index];
    valueLoop:
    for (var value = 1; value < 10; value++) {
      if (regionCell.possible[value]) {
        // Check if no duplicates allowed
        if (this.nodups) {
          if (setValues.contains(value)) continue valueLoop;
        } else {
          // Check if Row, Column or Box have duplicate for this region
          for (var axis in ['R', 'C', 'B']) {
            var label = regionCell.getAxisName(axis);
            if (axisValues.containsKey(label) &&
                axisValues[label]!.contains(value)) continue valueLoop;
          }
        }

        // Check for whisper from prior cell
        if (index > 0) {
          var priorValue = setValues.last;
          var diff = priorValue - value;
          if (diff < 0) diff = -diff;
          if (diff < this.difference) continue valueLoop;
        }

        if (index + 1 == regionCells.length) {
          setValues.add(value);
          newCombinations.add(setValues);
          break;
        } else {
          // Record values for Row, Column or Box for this region
          var newAxisValues = axisValues;
          if (!this.nodups) {
            newAxisValues = Map<String, List<int>>.from(axisValues);
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
          var combinations = _lineCombinations(
              index + 1, [...setValues, value], newAxisValues);
          newCombinations.addAll(combinations);
        }
      }
    }
    return newCombinations;
  }
}
