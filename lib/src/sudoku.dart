import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/dominoRegion.dart';
import 'package:sudoku/src/possible.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sandwichRegion.dart';
import 'package:sudoku/src/solveException.dart';
import 'package:sudoku/src/strategy/bugStrategy.dart';
import 'package:sudoku/src/strategy/hiddenGroupStrategy.dart';
import 'package:sudoku/src/strategy/hiddenSingleStrategy.dart';
import 'package:sudoku/src/strategy/lineBoxReductionStrategy.dart';
import 'package:sudoku/src/strategy/nakedGroupStrategy.dart';
import 'package:sudoku/src/strategy/simpleColouringStrategy.dart';
import 'package:sudoku/src/strategy/strategy.dart';
import 'package:sudoku/src/strategy/swordfishStrategy.dart';
import 'package:sudoku/src/strategy/updatePossibleStrategy.dart';
import 'package:sudoku/src/strategy/xyzWingStrategy.dart';
import 'package:sudoku/src/strategy/yWingStrategy.dart';
import 'package:sudoku/src/strategy/xWingStrategy.dart';

import 'mixedRegionGroup.dart';

typedef Solve = bool Function(Puzzle grid);

class SudokuRegion extends Region<Sudoku> {
  // late Killer killer;
  SudokuRegion(Sudoku puzzle, String name, Cells cells)
      : super(puzzle, name, name == 'G' ? 9 * 45 : 45, true, cells);
  String toString() => '$name';
}

class Sudoku implements Puzzle {
  Sudoku get sudoku => this;

  late bool singleStep;
  bool debug = false;

  late List<Cells> _grid;
  List<Cells> get grid => _grid;
  Cell getCell(int row, int col) => _grid[row - 1][col - 1];

  late Map<String, Region> _regions;
  Map<String, Region> get allRegions => _regions;

  /// Regions that are not simple SudokuRegion
  List<Region> get regions =>
      List<Region>.from(this.allRegions.values.where((region) =>
          region.runtimeType != SudokuRegion && !(region is RegionGroup)));

  /// Regions that are simple SudokuRegion
  List<Region> get nonets => List<Region>.from(this.allRegions.values.where(
      (region) => region.runtimeType == SudokuRegion && region.total == 45));

  /// RegionGroups
  List<RegionGroup> get regionGroups => List<RegionGroup>.from(
      this.allRegions.values.where((region) => region is RegionGroup));

  List<Region> getRegions(Cell cell) => List<Region>.from(
      cell.regions.where((region) => region.runtimeType != SudokuRegion));

  late Set<Cell> _updates;
  late List<String> _messages;
  bool _error = false;

  Set<Cell> get updates => _updates;
  List<String> get messages => _messages;
  String get messageString => _messages.join('\n');
  bool get error => _error;

  late UpdatePossibleStrategy updatePossibleStrategy;
  late HiddenSingleStrategy hiddenSingleStrategy;
  late NakedGroupStrategy nakedGroupStrategy3;
  late NakedGroupStrategy nakedGroupStrategy4;
  late HiddenGroupStrategy hiddenGroupStrategy3;
  late HiddenGroupStrategy hiddenGroupStrategy4;
  late PointingGroupStrategy pointingGroupStrategy;
  late LineBoxReductionStrategy lineBoxReductionStrategy;
  late XWingStrategy xWingStrategy;
  late SimpleColouringStrategy simpleColouringStrategy;
  late YWingStrategy yWingStrategy;
  late SwordfishStrategy swordfishStrategy;
  late XYZWingStrategy xyzWingStrategy;
  late BugStrategy bugStrategy;

  void _initRegions() {
    this._regions = <String, Region>{};
    _regions['G'] = SudokuRegion(this, 'G', <Cell>[]);
    for (var r = 1; r < 10; r++) {
      _regions['R$r'] = SudokuRegion(this, 'R$r', <Cell>[]);
      _regions['C$r'] = SudokuRegion(this, 'C$r', <Cell>[]);
      _regions['B$r'] = SudokuRegion(this, 'B$r', <Cell>[]);
    }
  }

  void _initProcessing() {
    _updates = {};
    _messages = [];
    updatePossibleStrategy = UpdatePossibleStrategy(this);
    hiddenSingleStrategy = HiddenSingleStrategy(this);
    nakedGroupStrategy3 = NakedGroupStrategy.minMax(this, 2, 3);
    nakedGroupStrategy4 = NakedGroupStrategy.minMax(this, 4, 4);
    hiddenGroupStrategy3 = HiddenGroupStrategy.minMax(this, 2, 3);
    hiddenGroupStrategy4 = HiddenGroupStrategy.minMax(this, 4, 4);
    pointingGroupStrategy = PointingGroupStrategy(this);
    lineBoxReductionStrategy = LineBoxReductionStrategy(this);
    xWingStrategy = XWingStrategy(this);
    simpleColouringStrategy = SimpleColouringStrategy(this);
    yWingStrategy = YWingStrategy(this);
    swordfishStrategy = SwordfishStrategy(this);
    xyzWingStrategy = XYZWingStrategy(this);
    bugStrategy = BugStrategy(this);
  }

  Sudoku([this.singleStep = false]) {
    _initRegions();
    _grid = List.generate(9,
        (row) => List.generate(9, (col) => Cell(row + 1, col + 1, _regions)));
    _initProcessing();
  }

  Sudoku.puzzle(List<String> newSudokuPuzzle, [this.singleStep = false]) {
    _initRegions();
    _grid = newSudokuPuzzle.asMap().entries.map((entry) {
      int row = entry.key;
      String val = entry.value;
      return List.generate(
        9,
        (col) => val[col] == '.'
            ? Cell(row + 1, col + 1, _regions)
            : Cell.value(row + 1, col + 1, int.parse(val[col]), _regions),
      );
    }).toList();
    _initProcessing();
  }

  void clearUpdates() {
    _messages = [];
    _updates = {};
    // for (var row in _grid) {
    //   for (var cell in row) {
    //     cell.clearUpdate();
    //   }
    // }
  }

  void getUpdates(StringBuffer result) {
    _messages.forEach((m) {
      result.writeln(debugPrint(m));
    });
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
    const rowBoxBottom = '╚═══╧═══╧═══╩═══╧═══╧═══╩═══╧═══╧═══╝';
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

  String debugPrint(String str) {
    if (debug) print(str);
    return str;
  }

  // ignore: unused_field
  var _iterations = 0;

  String solve({
    bool explain = false,
    bool showPossible = false,
    List<Strategy>? easyStrategies,
    List<Strategy>? toughStrategies,
    Function? toStr,
    bool first = true,
  }) {
    // Previous error?
    if (_error) return "Error";

    String stringFunc() => toStr == null ? toString() : toStr();

    addMixedRegionGroups();

    var result = StringBuffer();
    if (first) {
      result.writeln(stringFunc());
    }
    attemptSolve(
        explain, result, easyStrategies, toughStrategies, showPossible);
    if (!isSolved() && !_error) {
      // Find cell to try
      try {
        for (Cell tryCell in findCellToIterate()) {
          var tryValues = List.from(tryCell.possible.values);
          var state = saveState();
          // Iterate over values while fails until succeeds
          for (var value in tryValues) {
            var msg = debugPrint('Iterate $tryCell, value $value');
            if (explain) {
              result.writeln(msg);
            }
            tryCell.value = value;
            try {
              // Solve with new value
              var nextResult = solve(
                explain: explain,
                showPossible: showPossible,
                easyStrategies: easyStrategies,
                toughStrategies: toughStrategies,
                toStr: toStr,
                first: false,
              );
              if (isSolved()) {
                result.write(nextResult.toString());
                break;
              }
              // Failed to find solution
              var msg = debugPrint('Iterate failed to find solution!');
              if (explain) {
                result.writeln(msg);
              }
            } on SolveException catch (e) {
              // Invalid state
              var msg = debugPrint('Iterate exception ${e.message}!');
              if (explain) {
                result.writeln(msg);
              }
            }
            restoreState(state);
          }
        }
        // ignore: unused_catch_clause
      } on StateError catch (e) {
        // No iteration posible
      }
    }

    if (first) {
      if (explain) {
        result.writeln('Solution iterations=$_iterations');
      }
      result.write(stringFunc());
    }
    return result.toString();
  }

  void attemptSolve(
      bool explain,
      StringBuffer result,
      List<Strategy>? easyStrategies,
      List<Strategy>? toughStrategies,
      bool showPossible) {
    var updated = true;
    while (updated) {
      clearUpdates();
      if (isSolved()) {
        if (explain) result.writeln('Solved!');
        break;
      }
      // Easy
      updated = updatePossibleStrategy.solve();
      if (!updated) updated = hiddenSingleStrategy.solve();
      if (!updated) updated = nakedGroupStrategy3.solve();
      if (!updated) updated = hiddenGroupStrategy3.solve();
      if (!updated) updated = nakedGroupStrategy4.solve();
      if (!updated) updated = hiddenGroupStrategy4.solve();
      if (!updated) updated = pointingGroupStrategy.solve();
      if (!updated) updated = lineBoxReductionStrategy.solve();

      // Decorator strategies
      if (easyStrategies != null) {
        for (var strategy in easyStrategies) {
          if (!updated) updated = strategy.solve();
        }
      }

      // Tough
      if (!updated) updated = xWingStrategy.solve();
      if (!updated) updated = simpleColouringStrategy.solve();
      if (!updated) updated = yWingStrategy.solve();
      if (!updated) updated = swordfishStrategy.solve();
      if (!updated) updated = xyzWingStrategy.solve();
      if (!updated) updated = bugStrategy.solve();

      // Decorator strategies
      if (toughStrategies != null) {
        for (var strategy in toughStrategies) {
          if (!updated) updated = strategy.solve();
        }
      }

      _iterations++;
      if (updated) {
        if (explain) getUpdates(result);
        var possibleString = debugPrint(toPossibleString());
        if (showPossible) result.writeln(possibleString);
      }
    }
  }

  bool invokeStrategy(Solve strategy) {
    clearUpdates();
    var updated = strategy(this);
    return updated;
  }

  Cells getBox(int box) => List.from(allRegions['B$box']!.cells);
  Cells getRow(int row) => List.from(allRegions['R$row']!.cells);
  Cells getColumn(int col) => List.from(allRegions['C$col']!.cells);

  /// Update possible values in nonet [cells] for [cell] value, with label [explanation]
  ///
  /// For use by UI
  void cellUpdateNonet(Cell cell, Cells cells, String explanation) {
    var values = List.filled(9, false);
    assert(cell.value != null);
    values[cell.value! - 1] = true;
    for (var c in cells) {
      if (c != cell) {
        var value = c.value;
        if (value != null) {
          if (values[value - 1]) {
            this.addMessage(
                addExplanation(explanation, 'duplicate value $value'), true);
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
    for (var axis in ['B', 'R', 'C']) {
      var cells = getCellAxis(axis, cell);
      var location = addExplanation(explanation, cells[0].getAxisName(axis));
      cellUpdateNonet(cell, cells, location);
    }
  }

  Cells getCells3(String axis, int boxMajor, Cells cells) {
    var cells3 = <Cell>[];
    for (var boxMinor = 0; boxMinor < 3; boxMinor++) {
      late Cell cell;
      if (axis == 'R') {
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

  Cells getCellAxis(String axis, Cell cell) {
    if (axis == 'R') {
      return getRow(cell.row);
    } else if (axis == 'B') {
      return getBox(cell.box);
    } else {
      return getColumn(cell.col);
    }
  }

  Cells getMajorAxis(String axis, int major) {
    if (axis == 'R') {
      return getRow(major);
    } else if (axis == 'C') {
      return getColumn(major);
    } else {
      return getBox(major);
    }
  }

  Cells getMinorAxis(String axis, int minor) {
    if (axis == 'R') {
      return getColumn(minor);
    } else if (axis == 'C') {
      return getRow(minor);
    } else {
      return getBox(minor);
    }
  }

  Cell getAxisCell(String axis, int major, int minor) {
    if (axis == 'R') {
      return _grid[major - 1][minor - 1];
    } else if (axis == 'C') {
      return _grid[minor - 1][major - 1];
    } else {
      var row = floor3(major) + (minor - 1) ~/ 3;
      var col = ((major - 1) % 3) * 3 + 1 + (minor - 1) % 3;
      return _grid[row - 1][col - 1];
    }
  }

  bool axisEqual(String axis, Cell cell1, Cell cell2) {
    if (axis == 'R') {
      return cell1.row == cell2.row;
    } else {
      return cell1.col == cell2.col;
    }
  }

  void addMessage(String message, [bool error = false]) {
    _messages.add(message);
    _error |= error;
    if (_error) throw SolveException(message);
  }

  void cellUpdated(Cell cell, String explanation, String? message) {
    _updates.add(cell);
    if (message != null) {
      addMessage(addExplanation(explanation, message));
    }
  }

  void cellError(Cell cell, String explanation, String error) {
    addMessage(addExplanation(explanation, error), true);
  }

  Cells adjacentCells(Cell cell) {
    var row = cell.row;
    var col = cell.col;
    var cells = <Cell>[];
    if (row > 1) {
      cells.add(_grid[row - 2][col - 1]);
    }
    if (row < 9) {
      cells.add(_grid[row][col - 1]);
    }
    if (col > 1) {
      cells.add(_grid[row - 1][col - 2]);
    }
    if (col < 9) {
      cells.add(_grid[row - 1][col]);
    }
    return cells;
  }

  Cells kingsMoveCells(Cell cell) {
    var row = cell.row;
    var col = cell.col;
    var cells = <Cell>[];
    if (row > 1) {
      cells.add(_grid[row - 2][col - 1]);
    }
    if (row < 9) {
      cells.add(_grid[row][col - 1]);
    }
    if (col > 1) {
      cells.add(_grid[row - 1][col - 2]);
    }
    if (col < 9) {
      cells.add(_grid[row - 1][col]);
    }
    if (row > 1 && col > 1) {
      cells.add(_grid[row - 2][col - 2]);
    }
    if (row > 1 && col < 9) {
      cells.add(_grid[row - 2][col]);
    }
    if (row < 9 && col > 1) {
      cells.add(_grid[row][col - 2]);
    }
    if (row < 9 && col < 9) {
      cells.add(_grid[row][col]);
    }
    return cells;
  }

  Cells knightsMoveCells(Cell cell) {
    var row = cell.row;
    var col = cell.col;
    var cells = <Cell>[];
    if (row > 1) {
      if (col > 2) cells.add(sudoku.getCell(row - 1, col - 2));
      if (col < 8) cells.add(sudoku.getCell(row - 1, col + 2));
    }
    if (row > 2) {
      if (col > 1) cells.add(sudoku.getCell(row - 2, col - 1));
      if (col < 9) cells.add(sudoku.getCell(row - 2, col + 1));
    }
    if (row < 8) {
      if (col > 1) cells.add(sudoku.getCell(row + 2, col - 1));
      if (col < 9) cells.add(sudoku.getCell(row + 2, col + 1));
    }
    if (row < 9) {
      if (col > 2) cells.add(sudoku.getCell(row + 1, col - 2));
      if (col < 8) cells.add(sudoku.getCell(row + 1, col + 2));
    }
    return cells;
  }

  /// Find Rows/Columns/Boxes where values may appear up to occurrences times
  Map<int, Map<int, List<int>>> getValuePossibleIndexes(
      String axis, int occurrences) {
    var valuePossibleMajors = <int, Map<int, List<int>>>{};
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

  Cells? getLineCells(List<String> line) {
    var cells = <Cell>[];
    Cell? priorCell;
    String badCells = '';
    for (var location in line) {
      assert(location.length == 4);
      var row = int.tryParse(location[1]);
      var col = int.tryParse(location[3]);
      if (row == null ||
          col == null ||
          row < 1 ||
          row > 9 ||
          col < 1 ||
          col > 9) {
        badCells = badCells == '' ? location : '$badCells,$location';
        priorCell = null;
      } else {
        var cell = this.getCell(row, col);
        if (priorCell != null && !priorCell.adjacent(cell)) {
          this.addMessage('Non-adjacent Line cells $line', true);
          return null;
        }
        cells.add(cell);
        priorCell = cell;
      }
    }
    if (badCells != '') {
      sudoku.addMessage('Could not process Line $line cells $badCells', true);
      return null;
    }
    return cells;
  }

  bool updateCellCombinations(
      Cells cells, List<List<int>> combinations, String explanation) {
    var updated = false;
    if (combinations.length == 0)
      throw SolveException('No combinations for $explanation');
    List<Possible> unionCombinations =
        unionCellCombinations(cells, combinations);
    cells.forEachIndexed((index, cell) {
      if (cell.reducePossible(unionCombinations[index])) {
        updated = true;
        cellUpdated(cell, explanation, '$cell');
      }
    });
    return updated;
  }

  // Order cells by number of regions (i.e. constraints)
  // that they appear in, then number of values
  int cellIterateCompare(Cell a, Cell b) {
    var aRegions = getRegions(a).length;
    var bRegions = getRegions(b).length;
    var diff = bRegions - aRegions; // more regions first
    if (diff != 0) return diff;
    diff = a.possibleCount - b.possibleCount;
    if (diff != 0) return diff;
    return a.compareTo(b);
  }

  Iterable<Cell> findCellToIterate() sync* {
    // Find cells for values that appear twice in a Row/Column/Box
    var cells = <Cell>{};
    for (var axis in ['R', 'C', 'B']) {
      var valuePossibleTwice = sudoku.getValuePossibleIndexes(axis, 2);
      for (var majorEntry in valuePossibleTwice.values) {
        for (var entry in majorEntry.entries) {
          var major = entry.key;
          var minors = entry.value;
          for (var minor in minors) {
            cells.add(getAxisCell(axis, major, minor));
          }
        }
      }
    }
    // Order cells
    var sortedCells = Cells.from(cells);
    sortedCells.sort((a, b) => cellIterateCompare(a, b));
    for (var cell in sortedCells) {
      // Check cell has not been set since cells were computed
      if (!cell.isSet) yield cell;
    }
  }

  List<List<Possible>> saveState() {
    // State is just cell possible
    var state = List.generate(
        9,
        (row) =>
            _grid[row].map((cell) => Possible.from(cell.possible)).toList());
    return state;
  }

  void restoreState(List<List<Possible>> state) {
    state.forEachIndexed((rowIndex, row) {
      row.forEachIndexed((colIndex, possible) {
        _grid[rowIndex][colIndex].possible = Possible.from(possible);
      });
    });
    // Clear previous error
    _error = false;
  }

  var addedMixedRegionGroups = false;

  void addMixedRegionGroups() {
    if (addedMixedRegionGroups) return;
    addedMixedRegionGroups = true;

    // Creat RegionGroup for each group of intersecting regions
    var doneRegions = <Region>[];
    var doneCells = <Cell>[];
    for (var region in sudoku.regions) {
      if (!doneRegions.contains(region)) {
        addMixedRegionGroup(region, doneRegions, doneCells, true);
      }
    }
    // This creates lots of RegionGroups...
    // Create RegionGroup for nonets that do not have a corresponding Sandwich
    // for (var region in sudoku.nonets.where(
    //     (region) => !sudoku.regions.any((other) => other.equals(region)))) {
    //   if (!doneRegions.contains(region)) {
    //     doneRegions = <Region>[];
    //     doneCells = <Cell>[];
    //     addMixedRegionGroup(region, doneRegions, doneCells, true);
    //   }
    // }

    for (var axis in ['R', 'C', 'B']) {
      for (var major1 = 1; major1 < 10; major1++) {
        var cells = sudoku.getMajorAxis(axis, major1);
        var source = '$axis$major1';
        this.addMixedRegionGroupForCells(cells, source);
      }
    }

    if (debug) {
      print(allRegions.entries
          .where((element) =>
              element.key.length > 2 && element.key.substring(0, 2) == 'MG')
          .map((e) => e.value)
          .join('\n'));
    }
  }

  var _mixedGroupSeq = 1;

  void addMixedRegionGroup(
    Region region,
    List<Region> doneRegions,
    Cells doneCells,
    bool root, [
    List<Region>? newRegions,
    Cells? newCells,
  ]) {
    if (root) {
      newRegions = <Region>[];
      newCells = <Cell>[];
    } else {
      assert(newRegions != null && newCells != null);
    }
    doneRegions.add(region);
    newRegions!.add(region);
    for (var cell in region.cells) {
      if (!doneCells.contains(cell)) {
        doneCells.add(cell);
        newCells!.add(cell);
        for (var otherRegion in getRegions(cell)) {
          if (!doneRegions.contains(otherRegion)) {
            // Intersection of same regions handled by specific RegionGroups
            // Allow multiple Dominos with other types!
            if ((otherRegion.runtimeType == DominoRegion ||
                    !newRegions.any((region) =>
                        region.runtimeType == otherRegion.runtimeType)) &&
                true) {
              //  !(otherRegion.runtimeType == KillerRegion &&
              //     (otherRegion as KillerRegion).virtual)) {
              addMixedRegionGroup(otherRegion, doneRegions, doneCells, false,
                  newRegions, newCells);
            }
          }
        }
      }
    }
    // If multiple regions then create group
    // Exclude just Dominos which have specific RegionGroup
    if (root &&
        newRegions.length > 1 &&
        !newRegions.every((region) => region.runtimeType == DominoRegion)) {
      createMixedRegionGroup(newRegions, newCells!, '');
    }
  }

  bool addMixedRegionGroupByName(List<String> regionNames) {
    if (regionNames.any((name) => !allRegions.containsKey(name))) return false;
    var regions = regionNames.map((name) => allRegions[name]!).toList();
    var cells = regions.expand<Cell>((region) => region.cells).toSet().toList();
    createMixedRegionGroup(regions, cells, '');
    return true;
  }

  void addMixedRegionGroupForCells(Cells cells, String source) {
    var regions = <Region>[];
    var outieCells = <Cell>{};
    var groupCells = <Cell>{};
    for (var cell in cells) {
      for (var region
          in getRegions(cell).where((region) => !(region is SandwichRegion))) {
        if (!regions.contains(region)) {
          var regionCells = region.cells;
          var union =
              regionCells.where((regionCell) => cells.contains(regionCell));
          groupCells.addAll(union);
          var difference =
              regionCells.where((regionCell) => !cells.contains(regionCell));
          outieCells.addAll(difference);
          regions.add(region);
        }
      }
    }
    if (regions.isNotEmpty && regions.length > 1) {
      // Now create all region groups, combination processing limits inefficiency
      // Do not bother when outies dominate
      // ignore: dead_code
      if (true || outieCells.length < groupCells.length) {
        var cells = [...groupCells, ...outieCells];
        cells.sort((c1, c2) => c1.compareTo(c2));
        createMixedRegionGroup(regions, cells, source);
      }
    }
  }

  void createMixedRegionGroup(
      List<Region<dynamic>> regions, Cells cells, String nonet) {
    var name = 'MG${_mixedGroupSeq++}';
    var nodups = cellsInNonet(cells);
    var mixedRegionGroup = MixedRegionGroup(
      sudoku,
      name,
      nonet,
      nodups,
      regions,
      cells,
    );
    // Discard duplicates
    if (this.regionGroups.firstWhereOrNull(
            (regionGroup) => regionGroup.equalsGroup(mixedRegionGroup)) ==
        null) {
      allRegions[name] = mixedRegionGroup;
    } else
      _mixedGroupSeq--;
  }
}

String addExplanation(String explanation, String detail) =>
    (explanation != "" ? explanation + ", " : "") + detail;
