import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class YWingStrategy extends Strategy {
  YWingStrategy(grid) : super(grid, 'Y-Wing');

  bool solve() {
    var updated = false;
    var valuePossibleBoxes = grid.getValuePossibleIndexes('box', 2);
    for (var axis in ['row', 'column']) {
      var valuePossibleMajors = grid.getValuePossibleIndexes(axis, 2);
      for (var value = 1; value < 10; value++) {
        var majors = valuePossibleMajors[value];
        if (majors != null) {
          for (var major1 in majors.keys) {
            var minors1 = majors[major1]!;
            // Proceed if the two cells each have only two values
            assert(minors1.length == 2);
            var cell1 = grid.getAxisCell(axis, major1, minors1[0]);
            var cell2 = grid.getAxisCell(axis, major1, minors1[1]);
            if (cell1.possibleCount == 2 && cell2.possibleCount == 2) {
              var value1 = cell1.getOtherPossible(value);
              var value2 = cell2.getOtherPossible(value);
              if (value1 != value2) {
                // Look at boxes containing other value
                var box1 = cell1.box;
                var box2 = cell2.box;
                if (yWingCheckBox(valuePossibleBoxes, value1, box1, cell1,
                    value2, box2, axis)) updated = true;
                if (updated && grid.singleStep) return true;
                if (yWingCheckBox(valuePossibleBoxes, value2, box2, cell2,
                    value1, box1, axis)) updated = true;
                if (updated && grid.singleStep) return true;
                for (var other in [value1, value2]) {
                  // Look at rows that have other value twice
                  var majors2 = valuePossibleMajors[other];
                  if (majors2 != null) {
                    for (var major2 in majors2.keys) {
                      var minors2 = majors2[major2]!;
                      if (ListEquality().equals(minors1, minors2)) {
                        if (other == value2) {
                          if (yWingCheckSecondMajor(
                              axis,
                              major1,
                              major2,
                              minors1[0],
                              minors1[1],
                              other,
                              value1)) updated = true;
                          ;
                        } else {
                          if (yWingCheckSecondMajor(
                              axis,
                              major1,
                              major2,
                              minors1[1],
                              minors1[2],
                              other,
                              value2)) updated = true;
                        }
                        if (updated && grid.singleStep) return true;
                      }
                    }
                  }
                  ;
                }
              }
            }
          }
        }
      }
    }
    return updated;
  }

  bool yWingCheckBox(
      Map<int, Map<int, List<int>>> valuePossibleBoxes,
      int value,
      int box,
      Cell cell,
      int otherValue,
      int otherBox,
      String axis) {
    bool updated = false;
    var cells = grid.getBox(box);
    for (var otherCell in cells.where((element) => element != cell)) {
      if (otherCell.possibleCount == 2 &&
          otherCell.isPossible(value) &&
          otherCell.isPossible(otherValue) &&
          !grid.axisEqual(axis, otherCell, cell)) {
        // Match
        // Remove other value from box on cell axis
        var location = addExplanation(
            explanation, '$axis[${cell.row},${cell.col}] box[$box]');
        cells.where((c) => grid.axisEqual(axis, c, cell)).forEach((c) {
          if (c.clearPossible(otherValue)) {
            updated = true;
            grid.cellUpdated(
                cell, location, "remove value $otherValue from $c");
          }
        });
        location = addExplanation(
            explanation, '$axis[${cell.row},${cell.col}] box[$otherBox]');
        // Remove other value from other box on other cell axis
        cells = grid.getBox(otherBox);
        cells.where((c) => grid.axisEqual(axis, c, otherCell)).forEach((c) {
          if (c.clearPossible(otherValue)) {
            updated = true;
            grid.cellUpdated(
                cell, location, "remove value $otherValue from $c");
          }
        });
      }
    }
    return updated;
  }

  bool yWingCheckSecondMajor(
    String axis,
    int major1,
    int major2,
    int minor1,
    int minor2,
    int other,
    int value1,
  ) {
    var updated = false;
    var otherCell = grid.getAxisCell(axis, major2, minor1);
    var location = addExplanation(explanation, '$axis[$major1,$minor1]');
    if (otherCell.getOtherPossible(other) == value1) {
      var cell = grid.getAxisCell(axis, major2, minor2);

      if (cell.clearPossible(other)) {
        updated = true;
        grid.cellUpdated(cell, location, "remove value $other from $cell");
      }
    }
    return updated;
  }
}
