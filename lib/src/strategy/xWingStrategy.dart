import 'package:collection/collection.dart';

import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class XWingStrategy extends Strategy {
  XWingStrategy(grid) : super(grid, 'X-Wing');

  bool solve() {
    var updated = false;
    for (var axis in ['R', 'C']) {
      var valuePossibleTwiceMajors = grid.getValuePossibleIndexes(axis, 2);
      for (var value = 1; value < 10; value++) {
        var majors = valuePossibleTwiceMajors[value];
        if (majors != null) {
          majors.forEach((major1, minors1) {
            majors.forEach((major2, minors2) {
              if (major2 > major1 && ListEquality().equals(minors1, minors2)) {
                var location =
                    addExplanation(explanation, '$axis$major1,$axis$major2}]');
                // X Wing found
                // print('XWing value $value in $major1=$value1, $major2=$value2');
                // Remove the value from the two minor axes
                for (var minor in minors1) {
                  var cells = grid.getMinorAxis(axis, minor);
                  cells.forEach((cell) {
                    var major = cell.getAxis(axis);
                    if (major != major1 && major != major2) {
                      if (cell.clearPossible(value)) {
                        updated = true;
                        grid.cellUpdated(
                            cell, location, "remove value $value from $cell");
                      }
                    }
                  });
                }
              }
            });
          });
        }
      }
    }
    return updated;
  }
}
