import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/killerRegion.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/killerCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Killer extends PuzzleDecorator {
  late final bool partial;
  Map<String, Region> get regions => sudoku.regions;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Cages are Regions of type KillerRegion
  List<KillerRegion> get cages => List<KillerRegion>.from(this
      .regions
      .values
      .where((region) => region.runtimeType == KillerRegion));

  /// Get the puzzle Cage for a Cell
  KillerRegion? getCage(Cell cell) => cell.regions.firstWhereOrNull((region) =>
      region.runtimeType == KillerRegion &&
      !(region as KillerRegion).virtual) as KillerRegion?;

  /// Get all Cages for a Cell, including virtual cages
  List<KillerRegion> getAllCages(Cell cell) => List<KillerRegion>.from(
      cell.regions.where((region) => region.runtimeType == KillerRegion));

  Killer.puzzle(Puzzle puzzle, List<List<dynamic>> killerGrid,
      [partial = false]) {
    this.puzzle = puzzle;
    this.partial = partial;
    initKiller(killerGrid);
  }

  String toString() {
    var text = sudoku.toString();
    var regionText = regions.entries
        .where((entry) => entry.value.runtimeType == KillerRegion)
        .fold<String>(
            text, (text, entry) => '$text\n${entry.value.toString()}');
    return regionText;
  }

  late KillerCombinationsStrategy killerCombinationsStrategy;

  @override
  String solve({
    bool explain = false,
    bool showPossible = false,
    List<Strategy>? easyStrategies,
    List<Strategy>? toughStrategies,
  }) {
    var easyStrategies = <Strategy>[killerCombinationsStrategy];
    return puzzle.solve(
      explain: explain,
      showPossible: showPossible,
      easyStrategies: easyStrategies,
    );
  }

  void colourCages() {
    for (var cage in this.cages) {
      var adjacentCells = <Cell>[];
      for (var cell in cage.cells) {
        adjacentCells.addAll(sudoku.adjacentCells(cell));
      }
      var adjacentCages = adjacentCells
          .map((cell) => getCage(cell))
          .where((element) => element != null && element != cage)
          .toSet();
      var adjacentColours = adjacentCages.map((c) => c!.colour);
      cage.colour = 1;
      while (adjacentColours.contains(cage.colour)) {
        cage.colour = cage.colour! + 1;
      }
    }
  }

  bool validateCages() {
    var error = false;
    var grandTotal = 0;
    var numCells = 0;
    var allCells = [];
    for (var i = 0; i < cages.length; i++) {
      // Does the cage have duplicate cells
      var cage = cages[i];
      var cageCells = cage.cells;
      for (var i = 0; i < cageCells.length; i++) {
        for (var j = i + 1; j < cageCells.length; j++) {
          if (cageCells[i] == cageCells[j]) {
            sudoku.addMessage(
                'Cell ${cageCells[i]} is duplicated in cage!', true);
          }
        }
      }
      // Do the cell cages overlap?
      for (var j = i + 1; j < cages.length; j++) {
        for (var c1 in cages[i].cells) {
          if (cages[j].cells.any((cageCell) => cageCell == c1)) {
            sudoku.addMessage(
                'Cell ${c1} appears in more than one cage!', true);
            error = true;
          }
        }
      }
      // Sum totals and number of cells
      grandTotal += cages[i].total;
      numCells += cages[i].cells.length;
      allCells += cages[i].cells;
    }
    if (!partial && grandTotal != 45 * 9) {
      sudoku.addMessage(
          'Cages total is $grandTotal, should be ${45 * 9}', true);
      error = true;
    }
    if (!partial && numCells != 81) {
      var missingCells = '';
      for (var r = 1; r < 10; r++) {
        for (var c = 1; c < 10; c++) {
          if (!allCells.contains(sudoku.getCell(r, c))) {
            missingCells += '[$r,$c]';
          }
        }
      }
      sudoku.addMessage(
          'Cages only include $numCells cells, should be 81\nMissing cells: $missingCells',
          true);
      error = true;
    }
    return error;
  }

  void addVirtualCages() {
    // Examine 1, 2, 3, 4 consecutive rows/columns
    // Do not need to examine 5 because outies of 4 are innies of 5
    for (var axis in ['R', 'C']) {
      for (var size = 1; size <= 4; size++) {
        for (var major1 = 1; major1 <= 10 - size; major1++) {
          var cells = <Cell>[];
          for (var major2 = major1; major2 < major1 + size; major2++) {
            cells.addAll(sudoku.getMajorAxis(axis, major2));
          }
          var source =
              size == 1 ? '$axis$major1' : '$axis$major1-${major1 + size - 1}';
          this.addVirtualCage(cells, source);
        }
      }
    }
    // Adjacent box combinations
    var boxes = [
      [1, 2],
      [1, 4],
      [2, 3],
      [2, 5],
      [3, 6],
      [4, 5],
      [4, 7],
      [5, 6],
      [5, 8],
      [6, 9],
      [7, 8],
      [8, 9],
      [1, 2, 4],
      [1, 2, 5],
      [2, 3, 5],
      [2, 3, 6],
      [1, 4, 5],
      [2, 4, 5],
      [2, 5, 6],
      [3, 5, 6],
      [4, 5, 7],
      [4, 5, 8],
      [5, 6, 8],
      [5, 6, 9],
      [4, 7, 8],
      [5, 7, 8],
      [5, 8, 9],
      [6, 8, 9],
      [1, 2, 3, 4],
      [1, 2, 3, 5],
      [1, 2, 3, 6],
      [1, 2, 4, 5],
      [1, 2, 4, 7],
      [1, 2, 5, 6],
      [1, 2, 5, 8],
      [1, 4, 5, 6],
      [1, 4, 5, 7],
      [1, 4, 7, 8],
      [2, 3, 4, 5],
      [2, 3, 5, 6],
      [2, 3, 5, 8],
      [2, 3, 6, 9],
      [2, 4, 5, 6],
      [2, 4, 5, 8],
      [2, 5, 6, 8],
      [2, 5, 6, 9],
      [2, 5, 7, 8],
      [2, 5, 8, 9],
      [3, 4, 5, 6],
      [3, 5, 6, 8],
      [3, 5, 6, 9],
      [3, 6, 8, 9],
      [4, 5, 6, 7],
      [4, 5, 6, 8],
      [4, 5, 6, 9],
      [4, 5, 7, 8],
      [4, 5, 8, 9],
      [4, 7, 8, 9],
      [5, 6, 7, 8],
      [5, 6, 8, 9],
      [5, 7, 8, 9],
    ];

    for (var bs in boxes) {
      var cells = <Cell>[];
      var source = 'B';
      for (var b in bs) {
        cells.addAll(sudoku.getBox(b));
        if (source != 'B')
          source += ',$b';
        else
          source += '$b';
      }
      this.addVirtualCage(cells, source);
    }
  }

  static int _virtualSeq = 1; // Numbering for virtual cages
  static int _cageSeq = 1; // Numbering for specified cages

  addVirtualCage(List<Cell> cells, source) {
    // If cells include whole cages, make a virtual cage for the other cells
    var newLocations = <List<int>>[];
    var cellsTotal = 45 * (cells.length ~/ 9);
    var newTotal = cellsTotal;
    var unionCells = <Cell>[];
    var otherCagesTotal = 0;
    var otherLocations = <List<int>>[];
    var newCells = <Cell>[];
    var otherCells = <Cell>[];
    var otherOK = true;
    for (var cell in cells) {
      if (!unionCells.contains(cell)) {
        var cage = getCage(cell);
        if (cage == null || cage.virtual) {
          newCells.add(cell);
          newLocations.add([cell.row, cell.col]);
          otherOK = false;
        } else {
          var difference =
              cage.cells.where((cageCell) => !cells.contains(cageCell));
          if (difference.length > 0) {
            // Add the cell to the new cage
            newCells.add(cell);
            newLocations.add([cell.row, cell.col]);
            // Add non-included cells from this cell's cage to other cage
            var firstOtherCellForCage = true;
            for (final otherCageCell in difference) {
              var otherCell = otherCageCell;
              if (!otherCells.contains(otherCell)) {
                otherCells.add(otherCell);
                otherLocations.add([otherCell.row, otherCell.col]);
                if (firstOtherCellForCage) {
                  firstOtherCellForCage = false;
                  otherCagesTotal += cage.total;
                }
              }
            }
          } else {
            newTotal -= cage.total;
            unionCells.addAll(cage.cells);
          }
        }
      }
    }
    if (newTotal > 0 && newTotal != cellsTotal) {
      // If the cage is in a nonet, then it does not allow duplicates
      const maxCageLength = 7;
      assert(newLocations.length > 0);
      if (newLocations.length <= maxCageLength) {
        var name = 'KV${_virtualSeq++}';
        var nodups = cellsInNonet(newCells);
        var newCage = KillerRegion.locations(
          this,
          name,
          newTotal,
          newLocations,
          true,
          nodups,
          'i' + source, // Innie cage
        );
        if (this.cages.firstWhereOrNull((cage) => cage.equals(newCage)) ==
            null) {
          this.regions[name] = newCage;
        }
      }
      if (otherOK &&
          otherLocations.length > 0 &&
          otherLocations.length <= maxCageLength) {
        var name = 'KV${_virtualSeq++}';
        var nodups = cellsInNonet(otherCells);
        var otherTotal = otherCagesTotal - newTotal;
        var otherCage = KillerRegion.locations(
          this,
          'KV${_virtualSeq++}',
          otherTotal,
          otherLocations,
          true,
          nodups,
          'o' + source, // Outie cage
        );
        if (this.cages.firstWhereOrNull((cage) => cage.equals(otherCage)) ==
            null) {
          this.regions[name] = otherCage;
        }
      }
    }
  }

  void initKiller(List<List<dynamic>> killerGrid) {
    // Strategies
    killerCombinationsStrategy = KillerCombinationsStrategy(this);

    setKiller(killerGrid);
    if (sudoku.error) return;
    if (validateCages()) return;
    colourCages();
    addVirtualCages();
  }

  void setKiller(List<List<dynamic>> killerGrid) {
    var tryLocations =
        List.generate(9, (row) => List.generate(9, (col) => [row, col]))
            .expand((element) => element)
            .toList();
    while (tryLocations.length > 0) {
      var locations = tryLocations;
      tryLocations = <List<int>>[];
      for (final location in locations) {
        var row = location[0];
        var col = location[1];
        var processed = setCage(row + 1, col + 1, killerGrid[row][col]);
        if (!processed) {
          tryLocations.add([row, col]);
        }
      }
      if (tryLocations.length == locations.length) {
        // Failed to retry any location, so give up
        var cellStr = tryLocations.fold<String>(
            '',
            (str, loc) => str == ''
                ? 'R${loc[0] + 1}C${loc[1] + 1}'
                : str + ',R${loc[0] + 1}C${loc[1] + 1}');
        sudoku.addMessage('Could not process Killer cells $cellStr', true);
        return;
      }
    }
  }

  bool setCage(int row, int col, dynamic entry) {
    var processed = true;
    var cage = null;
    if (["D", "L", "R", "U"].contains(entry)) {
      // Get cage from referenced cell
      var r = row;
      var c = col;
      if (entry == "D") r++;
      if (entry == "L") c--;
      if (entry == "R") c++;
      if (entry == "U") r--;
      if (r >= 1 && r <= 9 && c >= 1 && c <= 9) {
        var cell = sudoku.getCell(r, c);
        cage = getCage(cell);
        if (cage != null) {
          var cell = sudoku.getCell(row, col);
          cage.cells.add(cell);
          cell.regions.add(cage);
        } else {
          processed = false;
        }
      }
    } else if (entry is int) {
      var value = entry;
      var cell = sudoku.getCell(row, col);
      cage = getCage(cell);
      if (cage != null) {
        sudoku.addMessage('Cell ${cell.name} already in Cage $cage', true);
        cage.cells.add(cell);
      } else {
        var name = 'K${_cageSeq++}';
        cage = KillerRegion.locations(
          this,
          name,
          value,
          [
            [row, col]
          ],
        );
        this.regions[name] = cage;
      }
    } else if (entry == '.') {
      // Ignore cell
    } else {
      sudoku.addMessage(
          'Unrecognised character $entry in Killer cell R${row}C$col', true);
    }

    return processed;
  }
}
