import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// A Y-Wing looks like an X-Wing - but with three corners, not four. The fourth
/// corner is where the candidate can be removed.
///
/// If two cells in a Row have candidates AB and BC, and another Row has candidates
/// AC in the same Column as AB, then C can be removed from the fourth corner. And
/// the same for Columns/Rows.
///
/// If two cells in a Box have candidates AB and BC, and another Column in a different
/// Box has candidates AC in the same Row as AB, then C can be removed from the
/// the AB Row of the AB box, and the BC Row of the AC box.
class YWingStrategy extends Strategy {
  YWingStrategy(sudoku) : super(sudoku, 'Y-Wing');

  Map<int, Map<int, List<int>>> getValueYPossibleIndexes(String axis) {
    var valuePossibleMajors = <int, Map<int, List<int>>>{};
    // Find Rows/Columns/Boxes where values may appear in doubles
    for (var major = 1; major < 10; major++) {
      var cells = sudoku.getMajorAxis(axis, major);
      var countPossibles = countCellsPossible(cells);
      for (var value = 1; value < 10; value++) {
        if (countPossibles[value - 1] >= 2) {
          if (valuePossibleMajors[value] == null) {
            valuePossibleMajors[value] = <int, List<int>>{};
          }
          for (var index = 0; index < cells.length; index++) {
            var cell = cells[index];
            if (cell.isPossible(value)) {
              if (cell.possibleCount == 2) {
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

  Iterable<List<int>> getDoubleIndexes(
      List<Cell> cells, List<int> indexes, int value) sync* {
    for (var index1 = 0; index1 < cells.length; index1++) {
      var cell1 = cells[index1];
      // Get cells with two possible values including requested value
      if (cell1.possibleCount == 2 && cell1.isPossible(value)) {
        for (var index2 = 0; index2 < cells.length; index2++) {
          var cell2 = cells[index2];
          // Get other cells with two overlapping possible values not including requested value
          if (cell2 != cell1 &&
              cell2.possibleCount == 2 &&
              cell2.isPossible(value) &&
              cell2.possible.subtract(cell1.possible).count == 1) {
            yield [index1, index2];
          }
        }
      }
    }
  }

  bool solve() {
    var updated = false;
    var valuePossibleBoxes = getValueYPossibleIndexes('B');
    for (var axis in ['R', 'C']) {
      var valuePossibleMajors = getValueYPossibleIndexes(axis);
      for (var value = 1; value < 10; value++) {
        var majors1 = valuePossibleMajors[value];
        if (majors1 != null) {
          for (var major1 in majors1.keys) {
            var minors1 = majors1[major1]!;

            var cells = sudoku.getMajorAxis(axis, major1);
            for (var pair1 in getDoubleIndexes(cells, minors1, value)) {
              var minor1 = pair1[0] + 1; // Two possible values
              var minor2 = pair1[1] + 1; // Two possible values
              var hingeCell = cells[minor1 - 1];
              var axisCell = cells[minor2 - 1];
              var otherValue =
                  axisCell.possible.subtract(hingeCell.possible).unique();
              var thirdValue =
                  hingeCell.possible.subtract(axisCell.possible).unique();
              // Check other majors for other value in double in minor1
              var majors2 = valuePossibleMajors[otherValue];
              if (majors2 != null) {
                for (var major2
                    in majors2.keys.where((major) => major != major1)) {
                  var minors2 = majors2[major2]!;
                  if (minors2.contains(minor1)) {
                    var otherCell = sudoku.getAxisCell(axis, major2, minor2);
                    if (otherCell.isPossible(thirdValue)) {
                      // Remove other value from major2, minor2
                      var location = addExplanation(explanation,
                          '$axis hinge ${hingeCell.name} $axis$major2');
                      var c = sudoku.getAxisCell(axis, major2, minor2);
                      if (c.clearPossible(otherValue)) {
                        updated = true;
                        sudoku.cellUpdated(
                            c, location, "remove value $otherValue from $c");
                      }
                    }
                  }
                }
              }
              // Check Box for hinge cell
              if (hingeCell.box != axisCell.box &&
                  valuePossibleBoxes[value] != null &&
                  valuePossibleBoxes[value]![hingeCell.box] != null) {
                var boxIndexes = valuePossibleBoxes[value]![hingeCell.box]!;
                var boxCells = sudoku.getMinorAxis('B', hingeCell.box);
                for (var pair2
                    in getDoubleIndexes(boxCells, boxIndexes, thirdValue)) {
                  var boxIndex1 = pair2[0]; // Two possible values
                  var boxIndex2 = pair2[1]; // Two possible values
                  if (boxCells[boxIndex1] == hingeCell) {
                    var otherCell = boxCells[boxIndex2];
                    if (otherCell.getAxis(axis) != hingeCell.getAxis(axis) &&
                        otherCell.isPossible(otherValue)) {
                      // Remove value from other cells in axis of box
                      var location = addExplanation(explanation,
                          '$axis hinge ${hingeCell.name} ${hingeCell.boxName}');
                      boxCells
                          .where((c) => sudoku.axisEqual(axis, c, hingeCell))
                          .forEach((c) {
                        if (c != hingeCell && c.clearPossible(otherValue)) {
                          updated = true;
                          sudoku.cellUpdated(
                              c, location, "remove value $otherValue from $c");
                        }
                      });
                      location = addExplanation(explanation,
                          '$axis hinge ${hingeCell.name} ${axisCell.boxName}');
                      // Remove other value from other box on other cell axis
                      var otherBoxCells = sudoku.getBox(axisCell.box);
                      otherBoxCells
                          .where((c) => sudoku.axisEqual(axis, c, otherCell))
                          .forEach((c) {
                        if (c.clearPossible(otherValue)) {
                          updated = true;
                          sudoku.cellUpdated(
                              c, location, "remove value $otherValue from $c");
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
