import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/possible.dart';
import 'package:sudoku/src/strategy/hiddenSingleStrategy.dart';
import 'package:sudoku/src/strategy/lineBoxReductionStrategy.dart';
import 'package:sudoku/src/strategy/nakedGroupStrategy.dart';
import 'package:sudoku/src/strategy/swordfishStrategy.dart';
import 'package:sudoku/src/strategy/updatePossibleStrategy.dart';
import 'package:sudoku/src/strategy/yWingStrategy.dart';
import 'package:sudoku/src/strategy/xWingStrategy.dart';

typedef Strategy = bool Function(Grid grid);

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
      updated = updatePossibleStrategy(this);
      if (!updated) updated = hiddenSingleStrategy(this);
      if (!updated) updated = nakedGroupStrategy(this);
      if (!updated) updated = pointingGroupStrategy(this);
      if (!updated) updated = lineBoxReductionStrategy(this);
      if (!updated) updated = xWingStrategy(this);
      if (!updated) updated = yWingStrategy(this);
      if (!updated) updated = swordfishStrategy(this);
      if (explain && updated) {
        printUpdates();
        print(toPossibleString());
      }
    }
    return;
  }

  bool invokeStrategy(Strategy strategy) {
    clearUpdates();
    var updated = strategy(this);
    return updated;
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

  void cellUpdated(Cell cell, String explanation, String? message) {
    _updates.add(cell);
    if (message != null) {
      _messages.add(addExplanation(explanation, message));
    }
  }

  void cellError(Cell cell, String explanation, String error) {
    cell.error = error;
    _messages.add(addExplanation(explanation, error));
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

String addExplanation(String explanation, String detail) =>
    (explanation != "" ? explanation + ", " : "") + detail;
