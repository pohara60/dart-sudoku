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
  List<List<int>>? regionCombinations() {
    var combinations = nextRegionCombinations(
      0,
      0,
      <int>[],
      <String, List<int>>{},
      remainingNoTotal,
      validNoTotal,
      false, // Unlimited combinations
      validWhisperValues, // Check Whisper values
    );
    return combinations;
  }

  int validWhisperValues(List<int> values) {
    // Check for whisper from prior cell
    if (values.length > 1) {
      var value = values[values.length - 1];
      var priorValue = values[values.length - 2];
      var diff = priorValue - value;
      if (diff < 0) diff = -diff;
      if (diff < this.difference) return 1; // continue
    }
    return 0;
  }
}
