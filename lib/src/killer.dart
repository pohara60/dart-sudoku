import 'package:collection/collection.dart';
import 'package:sudoku/src/cage.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/grid.dart';
import 'package:sudoku/src/puzzle.dart';

class Killer extends PuzzleDecorator {
  late List<Cage> cages;

  Killer.puzzle(Puzzle puzzle, List<List<dynamic>> killerGrid) {
    this.puzzle = puzzle;
    this.cages = <Cage>[];
    initKiller(killerGrid);
  }

  Grid get grid => puzzle.grid;

  @override
  String invokeAllStrategies(
      [bool explain = false, bool showPossible = false]) {
    return puzzle.invokeAllStrategies(explain, showPossible);
  }

  @override
  String get messageString => puzzle.messageString;

  Cage? getCage(cell) => this.cages.firstWhereOrNull(
      (cage) => cage.cells.map((cageCell) => cageCell.cell).contains(cell));

  void colourCages() {
    for (var cage in this.cages) {
      var adjacentCells = <Cell>[];
      for (var cageCell in cage.cells) {
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
      var cells = cage.cells;
      for (var i = 0; i < cells.length; i++) {
        for (var j = i + 1; j < cells.length; j++) {
          if (cells[i] == cells[j]) {
            grid.addMessage('Cell ${cells[i]} is duplicated in cage!', true);
          }
        }
      }
      // Do the cell cages overlap?
      for (var j = i + 1; j < cages.length; j++) {
        for (var c1 in cages[i].cells) {
          if (cages[j].cells.contains(c1)) {
            grid.addMessage('Cell $c1 appears in more than one cage!', true);
            error = true;
          }
        }
      }
      // Sum totals and number of cells
      grandTotal += cages[i].total;
      numCells += cages[i].cells.length;
      allCells += cages[i].cells;
    }
    if (grandTotal != 45 * 9) {
      // @ts-ignore
      grid.addMessage('Cages total is $grandTotal, should be ${45 * 9}', true);
      error = true;
    }
    if (numCells != 81) {
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
    for (var size = 1; size <= 5; size++) {
      for (var r = 1; r <= 10 - size; r++) {
        var cells = <Cell>[];
        for (var r2 = r; r2 < r + size; r2++) {
          cells.addAll(grid.getRow(r2));
        }
        var source = size == 1 ? 'R$r' : 'R$r-${r + size - 1}';
        this.addVirtualCage(cells, source);
      }
    }
    for (var size = 1; size <= 5; size++) {
      for (var c = 1; c <= 10 - size; c++) {
        var cells = <Cell>[];
        for (var c2 = c; c2 < c + size; c2++) {
          cells.addAll(grid.getColumn(c2));
        }
        var source = size == 1 ? 'C$c' : 'C$c-${c + size - 1}';
        this.addVirtualCage(cells, source);
      }
    }
    for (var size = 1; size <= 2; size++) {
      for (var r = 1; r <= 9; r += 3) {
        for (var c = 1; c <= 9; c += 3) {
          if (size == 1) {
            var b = grid.getCell(r, c).box;
            var cells = grid.getBox(b);
            var source = 'B$b';
            this.addVirtualCage(cells, source);
          }
          if (size == 2) {
            if (r < 6) {
              var cells = <Cell>[];
              var b1 = grid.getCell(r, c).box;
              cells.addAll(grid.getBox(b1));
              var b2 = grid.getCell(r + 3, c).box;
              cells.addAll(grid.getBox(b2));
              var source = 'B$b1,$b2';
              this.addVirtualCage(cells, source);
            }
            if (c < 6) {
              var cells = <Cell>[];
              var b1 = grid.getCell(r, c).box;
              cells.addAll(grid.getBox(b1));
              var b2 = grid.getCell(r, c + 3).box;
              cells.addAll(grid.getBox(b2));
              var source = 'B$b1,$b2';
              this.addVirtualCage(cells, source);
            }
          }
        }
      }
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
    for (var cell in cells) {
      if (!unionCells.contains(cell)) {
        var cage = getCage(cell);
        if (cage != null) {
          var difference =
              cage.cells.where((cageCell) => !cells.contains(cageCell.cell));
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
            unionCells.addAll(cage.cells.map((cageCell) => cageCell.cell));
          }
        }
      }
    }
    if (newTotal != 0 && newTotal != cellsTotal) {
      // If the cage is in a nonet, then it does not allow duplicates
      const maxCageLength = 5;
      if (newLocations.length <= maxCageLength) {
        var nodups = cellsInNonet(newCells);
        var newCage = Cage(
          this,
          newTotal,
          newLocations,
          true,
          nodups,
          source,
        );
        if (this.cages.firstWhereOrNull((cage) => cage.equals(newCage)) ==
            null) {
          this.cages.add(newCage);
        }
      }
      if (otherLocations.length <= maxCageLength) {
        var nodups = cellsInNonet(otherCells);
        var otherTotal = otherCagesTotal - newTotal;
        var otherCage =
            Cage(this, otherTotal, otherLocations, true, nodups, source + ' x');
        if (this.cages.firstWhereOrNull((cage) => cage.equals(otherCage)) ==
            null) {
          this.cages.add(otherCage);
        }
      }
    }
  }

  void initKiller(List<List<dynamic>> killerGrid) {
    setKiller(killerGrid);
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
        var cage = setCage(row + 1, col + 1, killerGrid[row][col]);
        if (cage == null) {
          tryLocations.add([row, col]);
        }
      }
      if (tryLocations.length == locations.length) {
        // Failed to retry any location, so give up
        return;
      }
    }
  }

  setCage(int row, int col, dynamic entry) {
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
          var cageCell = CageCell(cell);
          cage.cells.add(cageCell);
          cageCell.cage = cage;
          cageCell.cages = [cage];
        }
      }
    } else {
      if (entry is int) {
        var value = entry;
        var cell = grid.getCell(row, col);
        cage = getCage(cell);
        if (cage == null) {
          cage = Cage(this, value, [
            [row, col]
          ]);
          this.cages.add(cage);
        }
      }
    }
    return cage;
  }
}
