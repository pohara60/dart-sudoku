import 'package:sudoku/cell.dart';
import 'package:sudoku/possible.dart';

typedef Strategy = bool Function();

class Grid {
  late List<List<Cell>> _grid;
  Cell? _focus;
  late Set<Cell> _updates;
  late List<String> _messages;

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

  Grid() {
    _grid = List.generate(
        9, (row) => List.generate(9, (col) => Cell(row + 1, col + 1)));
    _init();
  }

  Grid.sudokuPuzzle(List<String> newSudokuPuzzle) {
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

  void value(int digit, bool updatePossible) {
    clearUpdates();
    assert(_focus != null);
    _focus!.value = digit;
    if (updatePossible) {
      cellUpdateAllNonet(_focus, '');
    }
  }

  /// Return [i] div 3 for 1-based index
  int floor3(i) {
    if (i >= 1 && i <= 3) {
      return 1;
    }
    if (i >= 4 && i <= 6) {
      return 4;
    }
    if (i >= 7 && i <= 9) {
      return 7;
    }
    throw Exception;
  }

  /// Return [i] mod 3 for 1-based index
  int mod3(i) {
    return (i - 1) % 3 + 1;
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
      _updates.add(cell);
      _messages.add(addExplanation(explanation, '$cell'));
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
            _updates.add(c);
            var message = addExplanation(
                explanation, 'remove value ${cell.value} from $c');
            _messages.add(message);
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
                _updates.add(c);
                messages.add(addExplanation(
                    explanation, "remove group $possible from $c"));
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
              _updates.add(cell);
              _messages.add(addExplanation(
                  locationAxis, "remove group $unique3 from $cell"));
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
}

Possible unionCellsPossible(List<Cell> cells) {
  var possibles = cells.map((cell) => cell.possible).toList();
  return unionPossible(possibles);
}
