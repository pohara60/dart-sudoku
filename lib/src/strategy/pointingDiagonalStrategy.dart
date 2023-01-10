import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// When there are only two possible cells for a value in a Diagonal
// then candidates for this value in the intersection of the Rows/Columns
// can be eliminated.
class PointingDiagonalStrategy extends Strategy {
  PointingDiagonalStrategy(sudoku) : super(sudoku, 'Pointing Diagonal');

  bool solve() {
    var updated = false;
    for (var axis in ['X']) {
      var valuePossibleTwiceMajors = sudoku.getValuePossibleIndexes(axis, 2);
      for (var value = 1; value < 10; value++) {
        var majors = valuePossibleTwiceMajors[value];
        if (majors != null) {
          majors.forEach((major, minors) {
            // print('PointingDiagonalStrategy major=$major, minors= $minors');
            var row1 = minors[0];
            var col1 = major == 1 ? minors[0] : 10 - minors[0];
            var row2 = minors[1];
            var col2 = major == 1 ? minors[1] : 10 - minors[1];
            var location =
                addExplanation(explanation, 'R${row1}C$col1,R${row2}C$col2');
            for (var cell in [
              sudoku.getCell(row1, col2),
              sudoku.getCell(row2, col1)
            ]) {
              // Remove the value from the intersection cells
              if (cell.clearPossible(value)) {
                updated = true;
                sudoku.cellUpdated(
                    cell, location, "remove value $value from $cell");
              }
            }
          });
        }
      }
    }
    return updated;
  }
}
