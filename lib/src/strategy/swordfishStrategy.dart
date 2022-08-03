import 'package:sudoku/src/grid.dart';

bool swordfishStrategy(Grid grid) {
  var explanation = 'Swordfish';
  return swordfish(grid, explanation);
}

bool swordfish(Grid grid, String explanation) {
  var updated = false;
  for (var axis in ['row', 'column']) {
    var valuePossibleMajors = grid.getValuePossibleIndexes(axis, 3);
    for (var value = 1; value < 10; value++) {
      var majors = valuePossibleMajors[value];
      if (majors != null && majors.length >= 3) {
        majors.forEach((major1, minors1) {
          majors.forEach((major2, minors2) {
            if (major1 < major2) {
              var minors = mergeLists(minors1, minors2);
              if (minors.length <= 3) {
                majors.forEach((major3, minors3) {
                  if (major2 < major3) {
                    minors = mergeLists(minors, minors3);
                    if (minors.length <= 3) {
                      var location = addExplanation(
                          explanation, '$axis[$major1,$major2,$major3}]');
                      // Remove the value from the three minor axes
                      for (var minor in minors) {
                        var cells = grid.getMinorAxis(axis, minor);
                        cells.forEach((cell) {
                          var major = axis == 'row' ? cell.row : cell.col;
                          if (major != major1 &&
                              major != major2 &&
                              major != major3) {
                            if (cell.clearPossible(value)) {
                              updated = true;
                              grid.cellUpdated(cell, location,
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
