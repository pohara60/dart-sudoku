import 'package:sudoku/src/possible.dart';

class Cell {
  int? _value;
  int? get value => _value;
  set value(int? value) {
    if (value != null) {
      _value = value;
      _possible = Possible.value(value);
    }
  }

  bool get isSet => _value != null;

  int _row, _col;
  int get row => _row;
  int get col => _col;
  String get name => 'R${_row}C${_col}';
  String get rowName => 'R${_row}';
  String get colName => 'C${_col}';
  int get box {
    var box = floor3(_row) + (_col - 1) ~/ 3;
    return box;
  }

  String get boxName => 'B${box}';
  // Zero-based index in 9 cells of box
  int get boxIndex {
    var index = (_row - 1) % 3 * 3 + (_col - 1) % 3;
    return index;
  }

  late Possible _possible;
  Possible get possible => _possible;
  int get possibleCount => _possible.count;

  late Region rowRegion;
  late Region colRegion;
  late Region boxRegion;
  late List<Region> regions;
  List<Region> get allRegions => [rowRegion, colRegion, boxRegion, ...regions];
  // TODO Killer primary cage

  _initRegions(regions) {
    rowRegion = regions['R$row']!;
    rowRegion.cells.add(this);
    colRegion = regions['C$col']!;
    colRegion.cells.add(this);
    boxRegion = regions['B$box']!;
    boxRegion.cells.add(this);
    this.regions = <Region>[];
  }

  Cell(this._row, this._col, Map<String, Region> regions) {
    _possible = Possible();
    _initRegions(regions);
  }
  Cell.value(this._row, this._col, int val, Map<String, Region> regions) {
    value = val;
    _initRegions(regions);
  }

  int getAxis(String axis) => axis == 'R'
      ? _row
      : axis == 'C'
          ? _col
          : box;
  String getAxisName(String axis) => axis == 'R'
      ? 'R$row'
      : axis == 'C'
          ? 'C$col'
          : axis == 'B'
              ? 'B$box'
              : name;

  bool clearPossible(int value) {
    return _possible.clear(value);
  }

  bool removePossible(Possible possible) {
    return _possible.remove(possible);
  }
}

class Region<Puzzle> {
  Puzzle puzzle;
  List<Cell> cells;
  String name;
  bool nodups;
  Region(Puzzle this.puzzle, String this.name, bool this.nodups,
      List<Cell> this.cells);
  String toString();
}

class SudokuRegion extends Region<Sudoku> {
  // late Killer killer;
  int total;
  SudokuRegion(Sudoku puzzle, String name, List<Cell> cells)
      : this.total = 45,
        super(puzzle, name, true, cells);
  String toString() => 'Sudoku $name';
}

class KillerRegion extends Region<Killer> {
  late Killer killer;
  late int total;
  late bool virtual;
  late String source;
  int? colour;

  KillerRegion(Killer killer, String name, int this.total, List<Cell> cells,
      [bool this.virtual = false, bool nodups = true, String this.source = ''])
      : super(killer, name, nodups, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  factory KillerRegion.locations(
      Killer killer, String name, int total, List<List<int>> locations,
      [bool virtual = false, bool nodups = true, String source = '']) {
    // Get cage cells
    var cells = <Cell>[];
    locations.forEach((element) {
      var cell = killer.sudoku.getCell(element[0], element[1]);
      cells.add(cell);
    });

    var region =
        KillerRegion(killer, name, total, cells, virtual, nodups, source);
    return region;
  }

  String toString() => 'Killer $name $total';
}

abstract class Puzzle {
  Puzzle.puzzle(puzzleList, singleStep);
  // String invokeAllStrategies({
  //   bool explain = false,
  //   bool showPossible = false,
  //   List<Strategy>? easyStrategies,
  //   List<Strategy>? toughStrategies,
  // });
  String get messageString;
  String toString();
  Sudoku get sudoku;
  Map<String, Region> get regions;
  String solve();
}

class Sudoku implements Puzzle {
  Sudoku get sudoku => this;

  late List<List<Cell>> _grid;
  List<List<Cell>> get grid => _grid;
  Cell getCell(int row, int col) => _grid[row - 1][col - 1];

  late Map<String, Region> _regions;
  Map<String, Region> get regions => _regions;
  late Set<Cell> _updates;
  late List<String> _messages;
  bool _error = false;

  late bool singleStep;
  bool debug = true;

  Set<Cell> get updates => _updates;
  List<String> get messages => _messages;
  String get messageString => _messages.join('\n');
  bool get error => _error;

  late LineBoxReductionStrategy lineBoxReductionStrategy;

  void _initRegions() {
    this._regions = <String, Region>{};
    for (var r = 1; r < 10; r++) {
      _regions['R$r'] = SudokuRegion(this, 'R$r', <Cell>[]);
      _regions['C$r'] = SudokuRegion(this, 'C$r', <Cell>[]);
      _regions['B$r'] = SudokuRegion(this, 'B$r', <Cell>[]);
    }
  }

  void _initProcessing() {
    _updates = {};
    _messages = [];
    lineBoxReductionStrategy = LineBoxReductionStrategy(this);
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
            if (_grid[r][c].possible[p + 1]) {
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

  String solve() {
    //return 'solve puzzle ${this.runtimeType}';
    // Previous error?
    if (_error) return "Error";

    var result = StringBuffer();
    result.writeln(toString());
    var updated = true;
    while (updated) {
      // clearUpdates();
      // if (isSolved()) {
      //   if (explain) result.writeln('Solved!');
      //   break;
      // }
      // Easy
      updated = false;
      if (!updated) updated = lineBoxReductionStrategy.solve();

      if (updated) {
        // if (explain) getUpdates(result);
        // var possibleString = debugPrint(toPossibleString());
        // if (showPossible) result.writeln(possibleString);
      }
    }
    result.writeln(toString());
    result.write(toPossibleString());
    return result.toString();
  }

  String debugPrint(String str) {
    //if (debug) print(str);
    return str;
  }

  void getUpdates(StringBuffer result) {
    _messages.forEach((m) {
      result.writeln(debugPrint(m));
    });
  }

  List<Cell> getBox(int box) => List.from(regions['B$box']!.cells);
  List<Cell> getRow(int row) => List.from(regions['R$row']!.cells);
  List<Cell> getColumn(int col) => List.from(regions['C$col']!.cells);

  List<Cell> getCellAxis(String axis, Cell cell) {
    if (axis == 'R') {
      return getRow(cell.row);
    } else if (axis == 'B') {
      return getBox(cell.box);
    } else {
      return getColumn(cell.col);
    }
  }

  List<Cell> getCells3(String axis, int boxMajor, List<Cell> cells) {
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

  void addMessage(String message, [bool error = false]) {
    _messages.add(message);
    _error |= error;
  }

  void cellUpdated(Cell cell, String explanation, String? message) {
    _updates.add(cell);
    if (message != null) {
      addMessage(addExplanation(explanation, message));
    }
  }
}

Possible unionCellsPossible(List<Cell> cells) {
  var possibles = cells.map((cell) => cell.possible).toList();
  return unionPossible(possibles);
}

String addExplanation(String explanation, String detail) =>
    (explanation != "" ? explanation + ", " : "") + detail;

abstract class PuzzleDecorator implements Puzzle {
  late final Puzzle puzzle;
}

class Killer extends PuzzleDecorator {
  late final bool partial;
  Map<String, Region> get regions => sudoku.regions;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku._messages.join('\n');

  Killer.puzzle(Puzzle puzzle, List<List<dynamic>> killerGrid,
      [partial = false]) {
    this.puzzle = puzzle;
    this.partial = partial;
    regions['K1'] = KillerRegion.locations(this, 'K1', 13, [
      [1, 4],
      [1, 5],
    ]);
    regions['K2'] = KillerRegion.locations(this, 'K2', 14, [
      [1, 6],
      [1, 7],
    ]);
    regions['K3'] = KillerRegion.locations(this, 'K3', 7, [
      [3, 8],
      [4, 7],
      [4, 8],
    ]);
    regions['K4'] = KillerRegion.locations(this, 'K4', 5, [
      [6, 7],
      [6, 8],
    ]);
/*
╠═══╪═══╪═══╬═══╪═══╪═══╬═══╪═══╪═══╣
║123│   │123║123│123│123║12 │12 │   ║
║ 56│   │ 5 ║ 56│ 56│ 56║4  │4  │  6║
║7  │ 89│   ║789│   │789║   │   │789║
╟───┼───┼───╫───┼───┼───╫───┼───┼───╢
║123│123│123║123│123│   ║   │   │   ║
║456│ 5 │ 5 ║ 5 │456│   ║   │   │ 56║
║   │   │   ║   │   │789║789│789│   ║
╟───┼───┼───╫───┼───┼───╫───┼───┼───╢
║   │   │   ║12 │12 │12 ║123│123│   ║
║  6│456│   ║456│456│456║   │   │ 5 ║
║7  │7  │ 89║789│789│789║   │   │ 89║
╠═══╪═══╪═══╬═══╪═══╪═══╬═══╪═══╪═══╣*/
    for (var cell in regions['K3']!.cells) {
      var impossible = Possible(false);
      for (var value in [3, 5, 6, 7, 8, 9]) impossible[value] = true;
      cell.removePossible(impossible);
    }
    for (var cell in regions['K4']!.cells) {
      var impossible = Possible(false);
      for (var value in [4, 5, 6, 7, 8, 9]) impossible[value] = true;
      cell.removePossible(impossible);
    }
    for (var cell in regions['R4']!.cells) {
      // if (cell.col < 7) {
      //   var impossible = Possible(false);
      //   for (var value in [4]) impossible[value] = true;
      //   cell.removePossible(impossible);
      // }
      if (cell.col > 8) {
        var impossible = Possible(false);
        for (var value in [1, 2, 3, 4, 5]) impossible[value] = true;
        cell.removePossible(impossible);
      }
    }
    for (var cell in regions['R5']!.cells) {
      if (cell.col > 6 && cell.col < 9) {
        var impossible = Possible(false);
        for (var value in [1, 2, 3, 4, 5, 6]) impossible[value] = true;
        cell.removePossible(impossible);
      }
      if (cell.col > 8) {
        var impossible = Possible(false);
        for (var value in [1, 2, 3, 4, 7, 8, 9]) impossible[value] = true;
        cell.removePossible(impossible);
      }
    }
    for (var cell in regions['R6']!.cells) {
      if (cell.col > 8) {
        var impossible = Possible(false);
        for (var value in [1, 2, 3, 4, 6, 7]) impossible[value] = true;
        cell.removePossible(impossible);
      }
    }
  }

  String toString() {
    var text = sudoku.toString();
    var regionText = regions.entries
        .where((entry) => entry.value.runtimeType == KillerRegion)
        .fold<String>(
            text, (text, entry) => '$text\n${entry.value.toString()}');
    return regionText;
  }

  String solve() {
    var str = sudoku.solve();
    return str;
  }
}

abstract class Strategy {
  final Puzzle puzzle;
  late final Sudoku sudoku;
  final String explanation;
  Strategy(this.puzzle, this.explanation) {
    this.sudoku = puzzle.sudoku;
  }
  bool solve();
}

class LineBoxReductionStrategy extends Strategy {
  LineBoxReductionStrategy(sudoku, [explanation = 'Line Box Reduction'])
      : super(sudoku, explanation);

  bool solve() {
    return allBoxReduction('B');
  }

  bool allBoxReduction(String target) {
    var updated = false;
    for (var box = 1; box < 10; box++) {
      if (lineBoxReduction(target, box)) updated = true;
    }
    return updated;
  }

  /// *lineBoxReduction* implement Point Group and Line Box Reduction
  ///
  /// If target is "B" then find unique value in Rows/Columns of Box
  /// and remove from rest of Box
  /// If target is not "B" then find unique value in Rows/Columns in Box
  /// and remove from rest of Row/Column
  bool lineBoxReduction(String target, int box) {
    var updated = false;
    var cells = sudoku.getBox(box);
    var location = addExplanation(explanation, cells[0].getAxisName('B'));
    // Check each Row then each Column of Box
    for (var axis in ['R', 'C']) {
      for (var boxMajor = 0; boxMajor < 3; boxMajor++) {
        // Three cells in Row/Column
        var cells3 = sudoku.getCells3(axis, boxMajor, cells);
        if (cells3.isEmpty) continue;
        // Other six cells in Box
        var boxCells6 = cells
            .where((cell) => !cell.isSet && !cells3.contains(cell))
            .toList();
        // Other six cells in Row/Column
        late List<Cell> axisCells6;
        late String locationAxis;
        axisCells6 = sudoku.getCellAxis(axis, cells3[0]);
        locationAxis =
            addExplanation(location, '${cells3[0].getAxisName(axis)}');
        axisCells6.removeWhere((cell) => cell.isSet || cells3.contains(cell));
        // Get cells to check and cells to update according to target
        late List<Cell> cells6;
        late List<Cell> updateCells;
        if (target == 'B') {
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
              sudoku.cellUpdated(
                  cell, locationAxis, "remove group $unique3 from $cell");
            }
          }
          // They can be removed from any overlapping unique killer regions
          for (var value = 1; value < 10; value++) {
            if (unique3[value]) {
              var uniqueCells = cells3.where((cell) => cell.possible[value]);
              var overlapRegions = uniqueCells
                  .expand((cell) => cell.regions)
                  .toSet()
                  .where((region) =>
                      region.nodups &&
                      region.cells.toSet().containsAll(uniqueCells))
                  .toSet();
              overlapRegions.forEach((region) {
                region.cells
                    .where((cell) => !uniqueCells.contains(cell))
                    .forEach((cell) {
                  if (cell.clearPossible(value)) {
                    updated = true;
                    sudoku.cellUpdated(
                        cell, locationAxis, "remove value $value from $cell");
                  }
                });
              });
            }
          }
        }
      }
    }
    return updated;
  }
}

var emptySudoku = [
  ".........",
  ".........",
  ".........",
  ".........",
  ".........",
  ".........",
  ".........",
  ".........",
  ".........",
].join('\n');
const LL = "L";
const RR = "R";
const UU = "U";
const DD = "D";
const XX = '.';
var killerPuzzle = [
  [XX, XX, 13, LL, XX, 14, LL, XX, XX],
  [XX, XX, 18, LL, 07, LL, LL, XX, XX],
  [08, 17, XX, UU, 09, LL, XX, 07, 10],
  [UU, UU, 11, XX, UU, XX, RR, UU, UU],
  [XX, RR, UU, LL, XX, 24, LL, LL, XX],
  [15, 20, LL, XX, 18, XX, 06, LL, 12],
  [UU, UU, XX, 08, UU, 15, XX, UU, UU],
  [XX, XX, RR, UU, UU, UU, LL, XX, XX],
  [XX, XX, 08, LL, XX, 08, LL, XX, XX],
];

void main() {
  var puzzleList = emptySudoku.split('\n');
  Puzzle puzzle = Sudoku.puzzle(puzzleList);
  puzzle = Killer.puzzle(puzzle, killerPuzzle, true);
  print(puzzle.toString());
  print(puzzle.solve());
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
