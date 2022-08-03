import 'package:collection/collection.dart';
import 'package:sudoku/cell.dart';
import 'package:sudoku/possible.dart';

typedef Strategy = bool Function();

class Grid {
  late List<List<Cell>> _grid;
  Cell? _focus;
  late Set<Cell> _updates;
  late List<String> _messages;

  late bool singleStep;

  get grid => _grid;
  Cell? get focus => _focus;
  Set<Cell> get updates => _updates;
  List<String> get messages => _messages;
  String get messageString => _messages.join('\n');

  set focus(Cell? focus) {
    if (focus != _focus) {
      clearUpdates();
      if (_focus != null) _focus!.isFocus = false;
      _focus = focus;
      if (focus != null) _focus!.isFocus = true;
    }
  }

  void _init() {
    focus = _grid[0][0];
    _updates = {};
    _messages = [];
  }

  void clearUpdates() {
    _messages = [];
    _updates = {};
    for (var row in _grid) {
      for (var cell in row) {
        cell.clearUpdate();
      }
    }
  }

  void printUpdates() {
    _messages.forEach((m) {
      print(m);
    });
  }

  Grid([this.singleStep = false]) {
    _grid = List.generate(
        9, (row) => List.generate(9, (col) => Cell(row + 1, col + 1)));
    _init();
  }

  Grid.sudokuPuzzle(List<String> newSudokuPuzzle, [this.singleStep = false]) {
    _grid = newSudokuPuzzle.asMap().entries.map((entry) {
      int row = entry.key;
      String val = entry.value;
      return List.generate(
        9,
        (col) => val[col] == '.'
            ? Cell(row + 1, col + 1)
            : Cell.value(row + 1, col + 1, int.parse(val[col])),
      );
    }).toList();
    _init();
  }

  String toString() {
    return _grid.fold(
        '',
        (previousValue, element) =>
            (previousValue == '' ? '' : previousValue + '\n') +
            element.fold(
                '',
                (previousValue, cell) =>
                    previousValue +
                    (cell.value == null ? '.' : cell.value.toString())));
  }

  String toPossibleString() {
    const rowBoxTop = '╔═══╤═══╤═══╦═══╤═══╤═══╦═══╤═══╤═══╗\n';
    const rowSeparator = '╟───┼───┼───╫───┼───┼───╫───┼───┼───╢\n';
    const rowBoxSeparator = '╠═══╪═══╪═══╬═══╪═══╪═══╬═══╪═══╪═══╣\n';
    const rowBoxBottom = '╚═══╧═══╧═══╩═══╧═══╧═══╩═══╧═══╧═══╝\n';
    const colBoxSeparator = '║';
    const colSeparator = '│';
    var result = StringBuffer();
    for (var r = 0; r < 9; r++) {
      if (r == 0) result.write(rowBoxTop);
      for (var t = 0; t < 3; t++) {
        for (var c = 0; c < 9; c++) {
          if (c == 0) result.write(colBoxSeparator);
          for (var p = t * 3; p < t * 3 + 3; p++) {
            if (_grid[r][c].isPossible(p + 1)) {
              result.write(((p + 1).toString()));
            } else {
              result.write(' ');
            }
          }
          if (c % 3 == 2)
            result.write(colBoxSeparator);
          else
            result.write(colSeparator);
        }
        result.write('\n');
      }
      if (r == 8)
        result.write(rowBoxBottom);
      else if (r % 3 == 2)
        result.write(rowBoxSeparator);
      else
        result.write(rowSeparator);
    }
    return result.toString();
  }

  void invokeAllStrategies(bool explain) {
    var updated = true;
    while (updated) {
      clearUpdates();
      if (isSolved()) {
        if (explain) print('Solved!');
        return;
      }
      updated = updatePossible();
      if (!updated) updated = hiddenSingleStrategy();
      if (!updated) updated = nakedGroupStrategy();
      if (!updated) updated = pointingGroupStrategy();
      if (!updated) updated = lineBoxReductionStrategy();
      if (!updated) updated = xWingStrategy();
      if (!updated) updated = yWingStrategy();
      if (!updated) updated = swordfishStrategy();
      if (explain && updated) {
        printUpdates();
        print(toPossibleString());
      }
    }
    return;
  }

  bool invokeStrategy(Strategy strategy) {
    clearUpdates();
    var updated = strategy();
    return updated;
  }

  bool updatePossible() {
    var explanation = 'Set Possible';
    var updated = false;
    _grid.forEach((r) => r.forEach((c) {
          if (allNonetsUpdateCell(c, explanation)) updated = true;
        }));
    return updated;
  }

  bool hiddenSingleStrategy() {
    var explanation = 'Hidden Single';
    var updated = false;
    _grid.forEach((r) => r.forEach((c) {
          if (cellHiddenSingle(c, explanation)) updated = true;
        }));
    return updated;
  }

  bool nakedGroupStrategy() {
    var explanation = 'Naked Group';
    return allNonetNakedGroup(explanation);
  }

  bool pointingGroupStrategy() {
    var explanation = 'Pointing Group';
    return allBoxPointingGroup(explanation);
  }

  bool lineBoxReductionStrategy() {
    var explanation = 'Line Box Reduction';
    return allLineBoxReduction(explanation);
  }

  bool xWingStrategy() {
    var explanation = 'X-Wing';
    return xWing(explanation);
  }

  bool yWingStrategy() {
    var explanation = 'Y-Wing';
    return yWing(explanation);
  }

  bool swordfishStrategy() {
    var explanation = 'Swordfish';
    return swordfish(explanation);
  }

  void value(int digit, bool updatePossible) {
    clearUpdates();
    assert(_focus != null);
    _focus!.value = digit;
    if (updatePossible) {
      cellUpdateAllNonet(_focus, '');
    }
  }

  /// Return cells in box [box]
  List<Cell> getBox(int box) {
    var cells = <Cell>[];
    var row = floor3(box);
    var col = ((box - 1) % 3) * 3 + 1;
    for (var r = row; r < row + 3; r++) {
      for (var c = col; c < col + 3; c++) {
        cells.add(_grid[r - 1][c - 1]);
      }
    }
    return cells;
  }

  /// Return cells in box that includes co-ordinates [irow] and [icol]
  List<Cell> getBoxForCell(int irow, int icol) {
    var cells = <Cell>[];
    var row = floor3(irow);
    var col = floor3(icol);
    for (var r = row; r < row + 3; r++) {
      for (var c = col; c < col + 3; c++) {
        cells.add(_grid[r - 1][c - 1]);
      }
    }
    return cells;
  }

  /// Return cells in row [row]
  List<Cell> getRow(int row) {
    var r = row;
    var cells = <Cell>[];
    for (var c = 1; c < 10; c++) {
      cells.add(_grid[r - 1][c - 1]);
    }
    return cells;
  }

  /// Return cells in column [col]
  List<Cell> getColumn(int col) {
    var c = col;
    var cells = <Cell>[];
    for (var r = 1; r < 10; r++) {
      cells.add(_grid[r - 1][c - 1]);
    }
    return cells;
  }

  /// Update [cell] possible values for values in box [cells], with label [explanation]
  bool nonetUpdateCell(Cell cell, List<Cell> cells, String explanation) {
    var updated = false;
    var values = List<bool>.filled(9, false);
    for (final c in cells) {
      if (c != cell) {
        var value = c.value;
        if (value != null) {
          if (cell.remove(value)) {
            updated = true;
          }
          if (values[value - 1]) {
            var error = addExplanation(explanation, 'duplicate value $value');
            c.error = error;
            messages.add(error);
          } else {
            values[value - 1] = true;
          }
        }
      }
    }
    if (updated) {
      _updates.add(cell);
      // Don't give messages about possible value updates
      // _messages.add(addExplanation(
      //     explanation, 'update possible cell ${cell.toString()}'));
    }
    return updated;
  }

  String addExplanation(String explanation, String detail) =>
      (explanation != "" ? explanation + ", " : "") + detail;

  /// Update [cell] possible values using its box, row and column
  bool allNonetsUpdateCell(Cell cell, String explanation) {
    var updated = false;

    if (cell.value != null) return false;

    // Remove known values from box, row, col
    var cells = getBoxForCell(cell.row, cell.col);
    var location = addExplanation(explanation, cells[0].location("box"));
    if (nonetUpdateCell(cell, cells, location)) updated = true;

    cells = getRow(cell.row);
    location = addExplanation(explanation, cells[0].location("row"));
    if (nonetUpdateCell(cell, cells, location)) updated = true;

    cells = getColumn(cell.col);
    location = addExplanation(explanation, cells[0].location("column"));
    if (nonetUpdateCell(cell, cells, location)) updated = true;

    return updated;
  }

  /// Check [cell] for unique possible value
  bool cellHiddenSingle(Cell cell, String explanation) {
    if (cell.value != null) return false;

    var updated = false;
    if (cell.checkUnique()) {
      updated = true;
    } else {
      // Check for a possible value not in box, row or column
      var cells = getBoxForCell(cell.row, cell.col);
      cells.remove(cell);
      var otherPossible = unionCellsPossible(cells);
      var difference = cell.possible.subtract(otherPossible);
      var value = difference.unique();
      if (value > 0) {
        cell.value = value;
        updated = true;
      }
    }
    if (updated) {
      cellUpdated(cell, explanation, '$cell');
    }
    return updated;
  }

  /// Update possible values in nonet [cells] for [cell] value, with label [explanation]
  void cellUpdateNonet(Cell cell, List<Cell> cells, String explanation) {
    var values = List.filled(9, false);
    assert(cell.value != null);
    values[cell.value! - 1] = true;
    for (var c in cells) {
      if (c != cell) {
        var value = c.value;
        if (value != null) {
          if (values[value - 1]) {
            c.error = addExplanation(explanation, 'duplicate value $value');
          } else {
            values[value - 1] = true;
          }
        } else {
          if (c.remove(cell.value!)) {
            cellUpdated(c, explanation, 'remove value ${cell.value} from $c');
          }
        }
      }
    }
  }

  /// Update box, row and column possible values for [cell] value
  void cellUpdateAllNonet(cell, explanation) {
    // Only done for known cells
    if (cell.value == null) return;

    // Remove known value from box, row, col
    var cells = getBoxForCell(cell.row, cell.col);
    var location = addExplanation(explanation, cells[0].location("box"));
    cellUpdateNonet(cell, cells, location);

    cells = getRow(cell.row);
    location = addExplanation(explanation, cells[0].location("row"));
    cellUpdateNonet(cell, cells, location);

    cells = getColumn(cell.col);
    location = addExplanation(explanation, cells[0].location("column"));
    cellUpdateNonet(cell, cells, location);
  }

  ///
  /// Recursive function to compute Groups (Pairs, Triples, etc) of possible values
  /// pC - list of cells to check
  /// g - required group size
  /// sC - current cells in group
  /// f - next index in check cells to try
  /// Returns list of groups, each of which is a list of cells
  ////
  List<List<Cell>> findGroups(List<Cell> pC, int g, List<Cell> sC, int f) {
    var groups = <List<Cell>>[];
    for (var index = f; index < pC.length; index++) {
      var c = pC[index];
      if (!sC.contains(c) && c.possibleCount <= g) {
        var newSC = [...sC, c];
        var possible = unionCellsPossible(newSC);
        if (possible.count <= g) {
          if (newSC.length == g) {
            groups.add(newSC);
          } else {
            // try adding cells to group
            var newGroups = findGroups(pC, g, newSC, index + 1);
            if (newGroups.length > 0) {
              groups.addAll(newGroups);
            }
          }
        }
      }
    }
    return groups;
  }

  bool nonetNakedGroup(List<Cell> cells, String explanation) {
    var anyUpdate = false;
    // Check cells for groups
    // Ignore known cells
    // Group maximum is half number of cells (because others must also form a group)
    var possibleCells = cells.where((cell) => !cell.isSet).toList();
    var groupMax = possibleCells.length ~/ 2;

    // Check for groups of 2 to groupMax cells
    var updated = true;
    while (updated) {
      updated = false;
      for (var gl = 1; gl <= groupMax; gl++) {
        var groups = findGroups(possibleCells, gl, [], 0);
        for (var group in groups) {
          var possible = unionCellsPossible(group);
          // Remove group from other cells
          for (var i = 0; i < possibleCells.length; i++) {
            var c = possibleCells[i];
            if (!group.contains(c)) {
              if (c.removePossible(possible)) {
                updated = true;
                anyUpdate = true;
                cellUpdated(c, explanation, "remove group $possible from $c");
              }
            }
          }
        }
      }
    }
    return anyUpdate;
  }

  bool allNonetNakedGroup(String explanation) {
    var updated = false;
    for (var row = 1; row < 10; row++) {
      var cells = getRow(row);
      if (nonetNakedGroup(cells, explanation)) updated = true;
    }
    for (var col = 1; col < 10; col++) {
      var cells = getColumn(col);
      if (nonetNakedGroup(cells, explanation)) updated = true;
    }
    for (var box = 1; box < 10; box++) {
      var cells = getBox(box);
      if (nonetNakedGroup(cells, explanation)) updated = true;
    }
    return updated;
  }

  List<Cell> getCells3(String axis, int boxMajor, List<Cell> cells) {
    var cells3 = <Cell>[];
    for (var boxMinor = 0; boxMinor < 3; boxMinor++) {
      late Cell cell;
      if (axis == 'row') {
        cell = cells[boxMajor * 3 + boxMinor];
      } else {
        cell = cells[boxMinor * 3 + boxMajor];
      }
      if (!cell.isSet) cells3.add(cell);
    }
    return cells3;
  }

  bool allBoxPointingGroup(String explanation) {
    return allBoxReduction('box', explanation);
  }

  bool allLineBoxReduction(String explanation) {
    return allBoxReduction('axis', explanation);
  }

  bool allBoxReduction(String target, String explanation) {
    var updated = false;
    for (var box = 1; box < 10; box++) {
      if (lineBoxReduction(target, box, explanation)) updated = true;
    }
    return updated;
  }

  /// *lineBoxReduction* implement Point Group and Line Box Reduction
  ///
  /// If target is "box" then find unique value in Rows/Columns of Box
  /// and remove from rest of Box
  /// If target is not "box" then find unique value in Rows/Columns in Box
  /// and remove from rest of Row/Column
  bool lineBoxReduction(String target, int box, String explanation) {
    var updated = false;
    var cells = getBox(box);
    var location = addExplanation(explanation, cells[0].location("box"));
    // Check each Row then each Column of Box
    for (var axis in ['row', 'column']) {
      for (var boxMajor = 0; boxMajor < 3; boxMajor++) {
        // Three cells in Row/Column
        var cells3 = getCells3(axis, boxMajor, cells);
        if (cells3.isEmpty) continue;
        // Other six cells in Box
        var boxCells6 = cells
            .where((cell) => !cell.isSet && !cells3.contains(cell))
            .toList();
        // Other six cells in Row/Column
        late List<Cell> axisCells6;
        late String locationAxis;
        if (axis == 'row') {
          axisCells6 = getRow(cells3[0].row);
          locationAxis = addExplanation(location, '$axis[${cells3[0].row}]');
        } else {
          axisCells6 = getColumn(cells3[0].col);
          locationAxis = addExplanation(location, '$axis[${cells3[0].col}]');
        }
        axisCells6.removeWhere((cell) => cell.isSet || cells3.contains(cell));
        // Get cells to check and cells to update according to target
        late List<Cell> cells6;
        late List<Cell> updateCells;
        if (target == 'box') {
          cells6 = boxCells6;
          updateCells = axisCells6;
        } else {
          cells6 = axisCells6;
          updateCells = boxCells6;
        }
        // Get values in three cells that do not appear in the six cells
        var possible3 = unionCellsPossible(cells3);
        var possible6 = unionCellsPossible(cells6);
        var unique3 = possible3.subtract(possible6);
        if (unique3.count > 0) {
          // The unique3 possible values can be removed from the Box/Row/Column
          for (var cell in updateCells) {
            if (cell.removePossible(unique3)) {
              updated = true;
              cellUpdated(
                  cell, locationAxis, "remove group $unique3 from $cell");
            }
          }
        }
      }
    }
    return updated;
  }

  bool isSolved() {
    var solved = _grid.fold<bool>(
        true,
        (previousValue, row) => row.fold(
            previousValue,
            (previousValue, cell) =>
                previousValue && cell.isSet ? true : false));
    return solved;
  }

  List<Cell> getMajorAxis(String axis, int major) {
    if (axis == 'row') {
      return getRow(major);
    } else if (axis == 'box') {
      return getBox(major);
    } else {
      return getColumn(major);
    }
  }

  List<Cell> getMinorAxis(String axis, int minor) {
    if (axis == 'row') {
      return getColumn(minor);
    } else {
      return getRow(minor);
    }
  }

  Map<int, Map<int, List<int>>> getValuePossibleIndexes(
      String axis, int occurrences) {
    var valuePossibleMajors = <int, Map<int, List<int>>>{};
    // Find Rows/Columns/Boxes where values may appear up to occurrences times
    for (var major = 1; major < 10; major++) {
      var cells = getMajorAxis(axis, major);
      var countPossibles = countCellsPossible(cells);
      for (var value = 1; value < 10; value++) {
        if (countPossibles[value - 1] > 1 &&
            countPossibles[value - 1] <= occurrences) {
          if (valuePossibleMajors[value] == null) {
            valuePossibleMajors[value] = <int, List<int>>{};
          }
          valuePossibleMajors[value]![major] = cells
              .expandIndexed<int>(
                  (index, cell) => cell.possible[value] ? [index + 1] : [])
              .toList();
        }
      }
    }
    return valuePossibleMajors;
  }

  bool xWing(String explanation) {
    var updated = false;
    for (var axis in ['row', 'column']) {
      var valuePossibleTwiceMajors = getValuePossibleIndexes(axis, 2);
      for (var value = 1; value < 10; value++) {
        var majors = valuePossibleTwiceMajors[value];
        if (majors != null) {
          majors.forEach((major1, minors1) {
            majors.forEach((major2, minors2) {
              if (major2 > major1 && ListEquality().equals(minors1, minors2)) {
                var location =
                    addExplanation(explanation, '$axis[$major1,$major2}]');
                // X Wing found
                // print('XWing value $value in $major1=$value1, $major2=$value2');
                // Remove the value from the two minor axes
                for (var minor in minors1) {
                  var cells = getMinorAxis(axis, minor);
                  cells.forEach((cell) {
                    var major = axis == 'row' ? cell.row : cell.col;
                    if (major != major1 && major != major2) {
                      if (cell.clearPossible(value)) {
                        updated = true;
                        cellUpdated(
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

  Cell getAxisCell(String axis, int major, int minor) {
    if (axis == 'row') {
      return _grid[major - 1][minor - 1];
    } else {
      return _grid[minor - 1][major - 1];
    }
  }

  bool axisEqual(String axis, Cell cell1, Cell cell2) {
    if (axis == 'row') {
      return cell1.row == cell2.row;
    } else {
      return cell1.col == cell2.col;
    }
  }

  bool yWing(String explanation) {
    var updated = false;
    var valuePossibleBoxes = getValuePossibleIndexes('box', 2);
    for (var axis in ['row', 'column']) {
      var valuePossibleMajors = getValuePossibleIndexes(axis, 2);
      for (var value = 1; value < 10; value++) {
        var majors = valuePossibleMajors[value];
        if (majors != null) {
          for (var major1 in majors.keys) {
            var minors1 = majors[major1]!;
            // Proceed if the two cells each have only two values
            assert(minors1.length == 2);
            var cell1 = getAxisCell(axis, major1, minors1[0]);
            var cell2 = getAxisCell(axis, major1, minors1[1]);
            if (cell1.possibleCount == 2 && cell2.possibleCount == 2) {
              var value1 = cell1.getOtherPossible(value);
              var value2 = cell2.getOtherPossible(value);
              if (value1 != value2) {
                // Look at boxes containing other value
                var box1 = cell1.box;
                var box2 = cell2.box;
                if (yWingCheckBox(valuePossibleBoxes, value1, box1, cell1,
                    value2, box2, axis, explanation)) updated = true;
                if (updated && singleStep) return true;
                if (yWingCheckBox(valuePossibleBoxes, value2, box2, cell2,
                    value1, box1, axis, explanation)) updated = true;
                if (updated && singleStep) return true;
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
                              value1,
                              explanation)) updated = true;
                          ;
                        } else {
                          if (yWingCheckSecondMajor(
                              axis,
                              major1,
                              major2,
                              minors1[1],
                              minors1[2],
                              other,
                              value2,
                              explanation)) updated = true;
                        }
                        if (updated && singleStep) return true;
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
      String axis,
      String explanation) {
    bool updated = false;
    var cells = getBox(box);
    for (var otherCell in cells.where((element) => element != cell)) {
      if (otherCell.possibleCount == 2 &&
          otherCell.isPossible(value) &&
          otherCell.isPossible(otherValue) &&
          !axisEqual(axis, otherCell, cell)) {
        // Match
        // Remove other value from box on cell axis
        var location = addExplanation(
            explanation, '$axis[${cell.row},${cell.col}] box[$box]');
        cells.where((c) => axisEqual(axis, c, cell)).forEach((c) {
          if (c.clearPossible(otherValue)) {
            updated = true;
            cellUpdated(cell, location, "remove value $otherValue from $c");
          }
        });
        location = addExplanation(
            explanation, '$axis[${cell.row},${cell.col}] box[$otherBox]');
        // Remove other value from other box on other cell axis
        cells = getBox(otherBox);
        cells.where((c) => axisEqual(axis, c, otherCell)).forEach((c) {
          if (c.clearPossible(otherValue)) {
            updated = true;
            cellUpdated(cell, location, "remove value $otherValue from $c");
          }
        });
      }
    }
    return updated;
  }

  bool yWingCheckSecondMajor(String axis, int major1, int major2, int minor1,
      int minor2, other, value1, String explanation) {
    var updated = false;
    var otherCell = getAxisCell(axis, major2, minor1);
    var location = addExplanation(explanation, '$axis[$major1,$minor1]');
    if (otherCell.getOtherPossible(other) == value1) {
      var cell = getAxisCell(axis, major2, minor2);

      if (cell.clearPossible(other)) {
        updated = true;
        cellUpdated(cell, location, "remove value $other from $cell");
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

  bool swordfish(String explanation) {
    var updated = false;
    for (var axis in ['row', 'column']) {
      var valuePossibleMajors = getValuePossibleIndexes(axis, 3);
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
                          var cells = getMinorAxis(axis, minor);
                          cells.forEach((cell) {
                            var major = axis == 'row' ? cell.row : cell.col;
                            if (major != major1 &&
                                major != major2 &&
                                major != major3) {
                              if (cell.clearPossible(value)) {
                                updated = true;
                                cellUpdated(cell, location,
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

  void cellUpdated(Cell cell, String location, String message) {
    _updates.add(cell);
    _messages.add(addExplanation(location, message));
  }
}

Possible unionCellsPossible(List<Cell> cells) {
  var possibles = cells.map((cell) => cell.possible).toList();
  return unionPossible(possibles);
}

List<int> countCellsPossible(List<Cell> cells) {
  var possibles = cells.map((cell) => cell.possible).toList();
  return countPossible(possibles);
}
