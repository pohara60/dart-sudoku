import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class XYZWingStrategy extends Strategy {
  XYZWingStrategy(grid) : super(grid, 'XYZ-Wing');

  Map<int, Map<int, List<int>>> getValueXYZPossibleIndexes(String axis) {
    var valuePossibleMajors = <int, Map<int, List<int>>>{};
    // Find Rows/Columns/Boxes where values may appear in a triple and a double
    for (var major = 1; major < 10; major++) {
      var cells = grid.getMajorAxis(axis, major);
      var countPossibles = countCellsPossible(cells);
      for (var value = 1; value < 10; value++) {
        if (countPossibles[value - 1] >= 2) {
          if (valuePossibleMajors[value] == null) {
            valuePossibleMajors[value] = <int, List<int>>{};
          }
          for (var index = 0; index < cells.length; index++) {
            var cell = cells[index];
            if (cell.isPossible(value)) {
              if (cell.possibleCount == 2 || cell.possibleCount == 3) {
                if (valuePossibleMajors[value]![major] == null) {
                  valuePossibleMajors[value]![major] = <int>[];
                }
                valuePossibleMajors[value]![major]!.add(index + 1);
              }
            }
          }
        }
      }
    }
    return valuePossibleMajors;
  }

  Iterable<List<int>> getTripleAndDoubleIndexes(
      List<Cell> cells, List<int> indexes, int value) sync* {
    for (var index3 = 0; index3 < cells.length; index3++) {
      var cell3 = cells[index3];
      // Get cells with three possible values including requested value
      if (cell3.possibleCount == 3 && cell3.isPossible(value)) {
        for (var index2 = 0; index2 < cells.length; index2++) {
          var cell2 = cells[index2];
          // Get cells with two possible values that are contained in the three values
          if (cell2.possibleCount == 2 &&
              cell2.isPossible(value) &&
              cell3.possible.subtract(cell2.possible).count == 1) {
            yield [index3, index2];
          }
        }
      }
    }
  }

  bool solve() {
    var updated = false;
    var valuePossibleBoxes = getValueXYZPossibleIndexes('box');
    for (var axis in ['row', 'column']) {
      var valuePossibleMajors = getValueXYZPossibleIndexes(axis);
      for (var value = 1; value < 10; value++) {
        var majors = valuePossibleMajors[value];
        if (majors != null) {
          for (var major1 in majors.keys) {
            var minors1 = majors[major1]!;
            var cells = grid.getMajorAxis(axis, major1);
            for (var pair1
                in getTripleAndDoubleIndexes(cells, minors1, value)) {
              var minor1 = pair1[0] + 1; // Three possible values
              var minor2 = pair1[1] + 1; // Two possible values
              var hingeCell = cells[minor1 - 1];
              var axisCell = cells[minor2 - 1];
              if (valuePossibleBoxes[value] != null &&
                  valuePossibleBoxes[value]![hingeCell.box] != null) {
                var boxIndexes = valuePossibleBoxes[value]![hingeCell.box]!;
                var boxCells = grid.getMinorAxis('box', hingeCell.box);
                for (var pair2
                    in getTripleAndDoubleIndexes(boxCells, boxIndexes, value)) {
                  var boxIndex1 = pair2[0]; // Three possible values
                  var boxIndex2 = pair2[1]; // Two possible values
                  if (boxCells[boxIndex1] == hingeCell) {
                    var otherCell = boxCells[boxIndex2];
                    if (otherCell.getAxis(axis) != hingeCell.getAxis(axis) &&
                        otherCell.possible.subtract(axisCell.possible).count ==
                            1) {
                      // Remove value from other cells in axis of box
                      var location = addExplanation(explanation,
                          '$axis[${hingeCell.row},${hingeCell.col}] box[${hingeCell.box}]');
                      boxCells
                          .where((c) => grid.axisEqual(axis, c, hingeCell))
                          .forEach((c) {
                        if (c != hingeCell && c.clearPossible(value)) {
                          updated = true;
                          grid.cellUpdated(
                              c, location, "remove value $value from $c");
                        }
                      });
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return updated;
  }
}
