import 'package:sudoku/src/possible.dart';
import 'package:sudoku/src/region.dart';

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

  bool isPossible(int value) {
    return _possible.isPossible(value);
  }

  bool clearPossible(int value) {
    return _possible.clear(value);
  }

  void clearUpdate() {}

  String format(bool showPossible) => _value != null
      ? _value.toString()
      : showPossible
          ? _possible.toString()
          : '';

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

  void togglePossible(int value) {
    _possible.toggle(value);
  }

  bool remove(int value) {
    //this.initPossible();
    if (_possible.isPossible(value)) {
      _possible.toggle(value);
      // var countTrue = 0;
      // var valueTrue;
      // for (var e = 1; e < 10; e++) {
      //   if (this._possible[e - 1]) {
      //     countTrue++;
      //     valueTrue = e;
      //   }
      // }
      // if (countTrue == 1) {
      //   this.value = valueTrue;
      // }
      return true;
    } else {
      return false;
    }
  }

  @override
  // toString() => _value != null ? _value.toString() : '';
  String toString() {
    var text = '$name = ${_possible.toString()}';
    return text;
  }

  bool checkUnique() {
    if (_value != null) return false;
    var unique = _possible.unique();
    if (unique > 0) {
      value = unique;
      return true;
    }
    return false;
  }

  bool removePossible(Possible possible) {
    return _possible.remove(possible);
  }

  bool reducePossible(Possible possible) {
    return _possible.reduce(possible);
  }

  bool removeOtherPossible(Possible possible) {
    return _possible.removeOther(possible);
  }

  getOtherPossible(int value) {
    return _possible.getOther(value);
  }

  int compareTo(Cell other) {
    if (row == other.row && col == other.col) return 0;
    if (row < other.row || row == other.row && col < other.col) return -1;
    return 1;
  }

  bool adjacent(Cell cell) {
    var rowDiff = this.row - cell.row;
    if (rowDiff < -1 || rowDiff > 1) return false;
    var colDiff = this.col - cell.col;
    if (colDiff < -1 || colDiff > 1) return false;
    return true;
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

bool cellsInNonet(List<Cell> cells) {
  if (Set.from(cells.map((x) => x.row)).length == 1) return true;
  if (Set.from(cells.map((x) => x.col)).length == 1) return true;
  if (Set.from(cells.map((x) => x.box)).length == 1) return true;
  return false;
}

Possible unionCellsPossible(List<Cell> cells) {
  var possibles = cells.map((cell) => cell.possible).toList();
  return unionPossible(possibles);
}

List<int> countCellsPossible(List<Cell> cells) {
  var possibles = cells.map((cell) => cell.possible).toList();
  return countPossible(possibles);
}

List<Cell> intersectionCells(List<Cell> l1, List<Cell> l2) {
  var result = l1.where((cell) => l2.contains(cell)).toList();
  return result;
}

List<Cell> remainderCells(List<Cell> l1, List<Cell> l2) {
  var result = l1.where((cell) => !l2.contains(cell)).toList();
  return result;
}

int fixedTotalCells(List<Cell> cells) {
  if (cells.length == 0) return 0;
  if (cells.length == 1) {
    var cell = cells[0];
    if (cell.isSet) return cell.value!;
    return 0;
  }
  int total = 0;
  var nodups = cellsInNonet(cells);
  if (nodups) {
    // Total is fixed if number of possible values is same as number of cells
    var unionPossible = unionCellsPossible(cells);
    if (unionPossible.count != cells.length) return 0;
    for (var value = 1; value < 10; value++) {
      if (unionPossible[value]) total += value;
    }
  } else {
    // Total is fixed if all cells are set
    if (cells.any((element) => !element.isSet)) return 0;
    total = cells.fold<int>(0, (total, cell) => total + cell.value!);
  }
  return total;
}

List<Possible> unionCellCombinations(
    List<Cell> cells, List<List<int>> combinations) {
  var unionCombinations =
      List.generate(cells.length, (index) => Possible(false));
  for (var combination in combinations) {
    for (var index = 0; index < combination.length; index++) {
      var value = combination[index];
      unionCombinations[index][value] = true;
    }
  }
  return unionCombinations;
}
