import 'package:collection/collection.dart';
import 'package:sudoku/src/cage.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/killerCombinations.dart';
import 'package:sudoku/src/strategy/shrinkCagesStrategy.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Killer extends PuzzleDecorator {
  late final List<Cage> cages;
  late final Map<Cell, Cage> cellCage;
  late final Map<Cell, CageCell> cellCageCell;
  late final bool partial;
  late KillerCombinationsStrategy killerCombinationsStrategy;
  late ShrinkCagesStrategy shrinkCagesStrategy;

  Killer.puzzle(Puzzle puzzle, List<List<dynamic>> killerGrid,
      [partial = false]) {
    this.puzzle = puzzle;
    this.cages = <Cage>[];
    this.cellCage = <Cell, Cage>{};
    this.cellCageCell = <Cell, CageCell>{};
    this.partial = partial;
    initKiller(killerGrid);
  }

  Grid get grid => puzzle.grid;

  @override
  String invokeAllStrategies({
    bool explain = false,
    bool showPossible = false,
    List<Strategy>? easyStrategies,
    List<Strategy>? toughStrategies,
  }) {
    var easyStrategies = <Strategy>[killerCombinationsStrategy];
    var toughStrategies = <Strategy>[shrinkCagesStrategy];
    return puzzle.invokeAllStrategies(
      explain: explain,
      showPossible: showPossible,
      easyStrategies: easyStrategies,
      toughStrategies: toughStrategies,
    );
  }

  @override
  String get messageString => puzzle.messageString;

  Cage? getCage(cell) => cellCage[cell];

  void colourCages() {
    for (var cage in this.cages) {
      var adjacentCells = <Cell>[];
      for (var cageCell in cage.cageCells) {
        adjacentCells.addAll(grid.adjacentCells(cageCell.cell));
      }
      var adjacentCages = adjacentCells
          .map((cell) => getCage(cell))
          .where((element) => element != cage)
          .toSet();
      var adjacentColours = adjacentCages.map((c) => c?.colour);
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
      var cageCells = cage.cageCells;
      for (var i = 0; i < cageCells.length; i++) {
        for (var j = i + 1; j < cageCells.length; j++) {
          if (cageCells[i].cell == cageCells[j].cell) {
            grid.addMessage(
                'Cell ${cageCells[i].cell} is duplicated in cage!', true);
          }
        }
      }
      // Do the cell cages overlap?
      for (var j = i + 1; j < cages.length; j++) {
        for (var c1 in cages[i].cageCells) {
          if (cages[j].cageCells.any((cageCell) => cageCell.cell == c1.cell)) {
            grid.addMessage(
                'Cell ${c1.cell} appears in more than one cage!', true);
            error = true;
          }
        }
      }
      // Sum totals and number of cells
      grandTotal += cages[i].total;
      numCells += cages[i].cageCells.length;
      allCells += cages[i].cageCells.map((cageCell) => cageCell.cell).toList();
    }
    if (!partial && grandTotal != 45 * 9) {
      grid.addMessage('Cages total is $grandTotal, should be ${45 * 9}', true);
      error = true;
    }
    if (!partial && numCells != 81) {
      var missingCells = '';
      for (var r = 1; r < 10; r++) {
        for (var c = 1; c < 10; c++) {
          if (!allCells.contains(grid.getCell(r, c))) {
            missingCells += '[$r,$c]';
          }
        }
      }
      grid.addMessage(
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
            cells.addAll(grid.getMajorAxis(axis, major2));
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
        cells.addAll(grid.getBox(b));
        if (source != 'B')
          source += ',$b';
        else
          source += '$b';
      }
      this.addVirtualCage(cells, source);
    }
  }

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
          var difference = cage.cageCells
              .where((cageCell) => !cells.contains(cageCell.cell));
          if (difference.length > 0) {
            // Add the cell to the new cage
            newCells.add(cell);
            newLocations.add([cell.row, cell.col]);
            // Add non-included cells from this cell's cage to other cage
            var firstOtherCellForCage = true;
            for (final otherCageCell in difference) {
              var otherCell = otherCageCell.cell;
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
            unionCells.addAll(cage.cageCells.map((cageCell) => cageCell.cell));
          }
        }
      }
    }
    if (newTotal > 0 && newTotal != cellsTotal) {
      // If the cage is in a nonet, then it does not allow duplicates
      const maxCageLength = 7;
      assert(newLocations.length > 0);
      if (newLocations.length <= maxCageLength) {
        var nodups = cellsInNonet(newCells);
        var newCage = Cage(
          this,
          newTotal,
          newLocations,
          true,
          nodups,
          'i' + source, // Innie cage
        );
        if (this.cages.firstWhereOrNull((cage) => cage.equals(newCage)) ==
            null) {
          this.cages.add(newCage);
        }
      }
      if (otherOK &&
          otherLocations.length > 0 &&
          otherLocations.length <= maxCageLength) {
        var nodups = cellsInNonet(otherCells);
        var otherTotal = otherCagesTotal - newTotal;
        var otherCage = Cage(
          this,
          otherTotal,
          otherLocations,
          true,
          nodups,
          'o' + source, // Outie cage
        );
        if (this.cages.firstWhereOrNull((cage) => cage.equals(otherCage)) ==
            null) {
          this.cages.add(otherCage);
        }
      }
    }
  }

  void initKiller(List<List<dynamic>> killerGrid) {
    // Strategies
    killerCombinationsStrategy = KillerCombinationsStrategy(this);
    shrinkCagesStrategy = ShrinkCagesStrategy(this);

    setKiller(killerGrid);
    if (grid.error) return;
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
        grid.addMessage('Could not process Killer cells $cellStr', true);
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
        var cell = grid.getCell(r, c);
        cage = getCage(cell);
        if (cage != null) {
          var cell = grid.getCell(row, col);
          CageCell.forCell(cell, cage, this);
        } else {
          processed = false;
        }
      }
    } else if (entry is int) {
      var value = entry;
      var cell = grid.getCell(row, col);
      cage = getCage(cell);
      if (cage == null) {
        cage = Cage(this, value, [
          [row, col]
        ]);
        this.cages.add(cage);
      }
    } else if (entry == '.') {
      // Ignore cell
    } else {
      grid.addMessage(
          'Unrecognised character $entry in Killer cell R${row}C$col', true);
    }

    return processed;
  }
}
