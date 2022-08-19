import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

/// A Swordfish is a 3 by 3 nine-cell pattern where a candidate is found on three
/// different rows (or columns) and they line up in the opposite direction.
/// Eventually we will fix three candidates somewhere in those cells which excludes
/// all other candidates in those units.
class SwordfishStrategy extends Strategy {
  SwordfishStrategy(sudoku) : super(sudoku, 'Swordfish');

  bool solve() {
    var updated = false;
    for (var axis in ['R', 'C']) {
      var valuePossibleMajors = sudoku.getValuePossibleIndexes(axis, 3);
      for (var value = 1; value < 10; value++) {
        var majors = valuePossibleMajors[value];
        if (majors != null && majors.length >= 3) {
          majors.forEach((major1, minors1) {
            majors.forEach((major2, minors2) {
              if (major1 < major2) {
                var minors12 = mergeLists(minors1, minors2);
                if (minors12.length <= 3) {
                  majors.forEach((major3, minors3) {
                    if (major2 < major3) {
                      var minors123 = mergeLists(minors12, minors3);
                      if (minors123.length <= 3) {
                        var location = addExplanation(explanation,
                            '$axis$major1,$axis$major2,$axis$major3');
                        // Remove the value from the three minor axes
                        for (var minor in minors123) {
                          var cells = sudoku.getMinorAxis(axis, minor);
                          cells.forEach((cell) {
                            var major = cell.getAxis(axis);
                            if (major != major1 &&
                                major != major2 &&
                                major != major3) {
                              if (cell.clearPossible(value)) {
                                updated = true;
                                sudoku.cellUpdated(cell, location,
                                    "remove value $value from $cell");
                              }
                            }
                          });
                        }
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

  List<int> mergeLists(List<int> list1, List<int> list2) {
    var result = <int>[];
    var index1 = 0;
    var index2 = 0;
    while (index1 < list1.length && index2 < list2.length) {
      if (list1[index1] == list2[index2]) {
        result.add(list1[index1]);
        index1++;
        index2++;
      } else if (list1[index1] < list2[index2]) {
        result.add(list1[index1]);
        index1++;
      } else {
        result.add(list2[index2]);
        index2++;
      }
    }
    while (index1 < list1.length) {
      result.add(list1[index1]);
      index1++;
    }
    while (index2 < list2.length) {
      result.add(list2[index2]);
      index2++;
    }
    return result;
  }
}
