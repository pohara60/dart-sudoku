import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/line.dart';
import 'package:sudoku/src/region.dart';

import 'possible.dart';

enum ColourValue {
  UNKNOWN,
  LOW,
  MEDIUM,
  HIGH,
}

abstract class LineRegion extends Region<Line> {
  late Line line;

  // Colour variables
  late int colours; // Number colours, 1=none
  late int numEachColour;
  late bool isOddCell;
  late List<Possible> colourPossible;
  late Possible colourAllPossible;
  late List<ColourValue> colourValues;
  late Map<ColourValue, Possible> colourValuePossible;

  // Computation state
  bool doInitState = true;
  late Map<Cell, int> cellColour = <Cell, int>{};
  late Map<String, Cells> regionCells = <String, Cells>{};

  bool initState() {
    if (!doInitState) return false;
    cellColour = <Cell, int>{};
    regionCells = <String, Cells>{};
    doInitState = false;
    numEachColour = 9 ~/ this.colours;
    isOddCell = numEachColour * this.colours != 9;
    colourValues = List.generate(this.colours, (index) => ColourValue.UNKNOWN);
    colourPossible = <Possible>[];
    for (var i = 0; i < numEachColour; i++) {
      var possible = Possible(false);
      if (colours == 2) {
        possible[i + 1] = true;
        possible[9 - i] = true;
      } else {
        assert(colours == 3, 'Num colours must be 2 or 3');
        possible[i + 1] = true;
        possible[i + 4] = true;
        possible[i + 7] = true;
      }
      colourPossible.add(possible);
    }
    colourAllPossible = Possible(true);
    if (isOddCell) colourAllPossible[5] = false;
    colourValuePossible = <ColourValue, Possible>{};
    if (colours == 2) {
      colourValuePossible[ColourValue.LOW] = Possible.list([1, 2, 3, 4]);
      colourValuePossible[ColourValue.MEDIUM] = Possible.list([5]);
      colourValuePossible[ColourValue.HIGH] = Possible.list([6, 7, 8, 9]);
    }
    if (colours == 3) {
      colourValuePossible[ColourValue.LOW] = Possible.list([1, 2, 3]);
      colourValuePossible[ColourValue.MEDIUM] = Possible.list([4, 5, 6]);
      colourValuePossible[ColourValue.HIGH] = Possible.list([7, 8, 9]);
    }
    return true;
  }

  void clearState() {
    doInitState = true;
  }

  LineRegion.new(Line line, String name, Cells cells,
      {bool nodups = true, int total = 5, int colours = 1})
      : super(line, name, total, nodups, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
    this.colours = colours;
  }

  toString() {
    var sortedCells = cells;
    var text = '$name:${sortedCells.cellsString()}';
    return text;
  }

  @override
  List<List<int>>? regionCombinations() {
    var combinations = nextRegionCombinations(
      0,
      0,
      <int>[],
      <String, List<int>>{},
      remainingNoTotal,
      validNoTotal,
      false, // Unlimited combinations
      validLineRegionValues, // Check Line values
    );
    return combinations;
  }

  int validLineRegionValues(List<int> values, Cells valueCells) {
    return validLineValues(values, valueCells, this.cells);
  }

  int validLineValues(List<int> values, Cells valueCells, Cells cells) {
    throw UnimplementedError();
  }

  int validLineGroupValues(List<int> values, Cells valueCells, Cells cells,
      puzzle, List<Region>? regions) {
    var line = puzzle as Line;

    // Check line for cells in order
    var doneRegions = <LineRegion>[];
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      var cell = valueCells[valueIndex];
      var value = values[valueIndex];
      // Check line(s)
      for (var lineRegion in line.getLines(cell).where((lineRegion) =>
          !doneRegions.contains(lineRegion) &&
          (regions == null || regions.contains(lineRegion)))) {
        var index = lineRegion.cells.indexOf(cell);
        assert(index != -1);
        var lineValues = <int>[];
        Cells lineCells = <Cell>[];
        lineValues.add(value);
        lineCells.add(cell);
        // Check if other cells in line have values
        for (var priorValueIndex = valueIndex - 1;
            priorValueIndex >= 0;
            priorValueIndex--) {
          var priorCell = valueCells[priorValueIndex];
          var priorValue = values[priorValueIndex];
          var priorIndex = lineRegion.cells.indexOf(priorCell);
          if (priorIndex != -1) {
            // In line
            lineValues.add(priorValue);
            lineCells.add(priorCell);
          }
        }

        var result = lineRegion.validLineRegionValues(lineValues, lineCells);
        if (result != 0) return result;

        doneRegions.add(lineRegion);
      }
    }
    return 0;
  }

  bool regionColouring(String location) {
    var updated = false;
    if (this.colours == 1) return updated;

    if (initState()) {
      // Colour cells, create list of cells for Boxes/Rows/Columns
      void addRegionCell(Cell cell, String region) {
        regionCells[region] = (regionCells[region] == null
            ? []
            : regionCells[region]!)
          ..add(cell);
      }

      var colour = 0;
      for (var cell in this.cells) {
        cellColour[cell] = colour;
        colour = (colour + 1) % this.colours;
        addRegionCell(cell, cell.boxName);
        addRegionCell(cell, cell.rowName);
        addRegionCell(cell, cell.colName);
        // Diagonals if SudokuX regions
        for (var diagonal in cell.xName) {
          if (puzzle.allRegions.containsKey(diagonal))
            addRegionCell(cell, diagonal);
        }
      }
    }

    // If Region is solved then nothing more useful to do
    if (this.cells.every((cell) => cell.isSet)) return false;

    // Check each region to set colours
    for (var regionName in regionCells.keys) {
      var cells = regionCells[regionName]!;
      var allCells = puzzle.allRegions[regionName]!.cells;
      var knownColours = <int>{};
      var unknownColour = -1;
      for (var colour = 0; colour < this.colours; colour++) {
        var count = cells.where((cell) => colour == cellColour[cell]!).length;
        if (count == numEachColour)
          knownColours.add(colour);
        else
          unknownColour = colour;
      }
      // If all but one colour known, then may colour other cells
      if (knownColours.length == this.colours - 1) {
        var otherCells = remainderCells(allCells, cells);
        Cell? oddCell = null;
        if (isOddCell) {
          oddCell = otherCells.firstWhereOrNull((cell) => cell.value == 5);
          if (oddCell != null) {
            otherCells.remove(oddCell);
            if (!cellColour.containsKey(oddCell)) {
              cellColour[oddCell] = -1; // No colour
            }
          }
        }
        for (var cell in otherCells) {
          if (!cellColour.containsKey(cell)) {
            if (!isOddCell || oddCell != null || !cell.isPossible(5)) {
              cellColour[cell] = unknownColour;
              puzzle.sudoku.cellUpdated(
                  cell, location, "$cell colour ${cellColour[cell]}");
              updated =
                  true; // Possible not updated yet but needed to get message
            }
          }
        }
      }
      // Update unique colour possible based on colours
      // e.g. for Whisper with two colours, the colour possible are 19, 28, 37, 46
      for (var colour = 0; colour < this.colours; colour++) {
        var colourCells = allCells.where((cell) => cellColour[cell] == colour);
        for (var cell in colourCells) {
          var possible = getColourPossible(cell);
          if (possible != null) {
            // Remove colour possible from other cells
            for (var otherCell
                in colourCells.where((element) => element != cell)) {
              if (otherCell.removePossible(possible)) {
                puzzle.sudoku.cellUpdated(otherCell, location,
                    "remove ${cell.possible} from $otherCell");
                updated = true;
              }
            }
          }
        }
      }
      // Check cells that may have colour for naked single colour possible
      for (var colour = 0; colour < this.colours; colour++) {
        var possibleColourCells = allCells
            .where((cell) =>
                cellColour[cell] == null || cellColour[cell] == colour)
            .toList();
        var cellPossibles = List.generate(
            possibleColourCells.length,
            (index) => possibleColourCells[index]
                .possible
                .intersect(colourAllPossible));
        for (var i = 0; i < possibleColourCells.length; i++) {
          var cell = possibleColourCells[i];
          // Check all intersecting regions
          for (var axis in ['B', 'R', 'C', 'X1', 'X2']) {
            var otherCells = puzzle.sudoku
                .getMajorAxis(axis, cell.getAxis(axis))
                .where((element) => element != cell);
            for (var otherCell in otherCells) {
              var possible = getColourPossible(otherCell);
              if (possible != null) {
                if (cellColour[otherCell] == colour) {
                  // Remove fixed colour possible in cell of same colour from cell possible
                  cellPossibles[i].remove(possible);
                } else if (cellColour[otherCell] != null && this.colours == 2) {
                  // otherCell is other colour with fixed colourPossible
                  if (cell.possible.equals(possible)) {
                    // This cell has the fixed colourPossible so others cannot
                    for (var cellPossible in cellPossibles
                        .whereIndexed((index, element) => index != i)) {
                      cellPossible.remove(possible);
                    }
                  }
                }
              }
            }
          }
        }
        // If a colour possible only appears in one cell, then we can set that cell
        for (var possible in colourPossible) {
          var cellIndex = -1;
          if (null !=
              cellPossibles.singleWhereIndexedOrNull((index, element) {
                if (element.intersect(possible).count == 0) return false;
                cellIndex = index;
                return true;
              })) {
            var cell = possibleColourCells[cellIndex];
            // Set colour
            if (cellColour[cell] == null) {
              cellColour[cell] = colour;
              puzzle.sudoku.cellUpdated(cell, location, "$cell colour $colour");
              updated = true;
            }
            // Set possible
            if (cell.removeOtherPossible(possible)) {
              puzzle.sudoku.cellUpdated(cell, location, "set possible $cell");
              updated = true;
            }
          }
        }
      }
    }
    // Check if know colour value(s) for region
    var colourUpdated = true; // Loop until no update
    for (var i = 0; colourUpdated && i < this.colours; i++) {
      colourUpdated = false;
      for (var colour = 0; colour < this.colours; colour++) {
        // Does a colour cell have known colour value
        var colourCells =
            this.cells.where((cell) => cellColour[cell] == colour);
        if (colourValues[colour] == ColourValue.UNKNOWN) {
          var colourValue = colourCells
              .map<ColourValue>((e) => knownColourValue(e))
              .firstWhereOrNull((element) => element != ColourValue.UNKNOWN);
          if (colourValue != null) {
            puzzle.sudoku
                .addMessage('$location colour $colour = ${colourValue.name}');
            colourValues[colour] = colourValue;
            colourUpdated = true;
          }
        }
        var colourValue = colourValues[colour];
        if (colourValue != ColourValue.UNKNOWN) {
          // Remove other impossible values from cells of this colour
          var possible = colourValuePossible[colourValue]!;
          for (var cell in colourCells) {
            if (cell.removeOtherPossible(possible)) {
              puzzle.sudoku.cellUpdated(
                  cell, location, "colour ${colourValue.name} possible $cell");
              updated = true;
            }
          }
          // Remove possible values from cells of other colour
          var otherColourCells = this.cells.where(
              (cell) => cellColour[cell] != null && cellColour[cell] != colour);
          for (var otherCell in otherColourCells) {
            if (otherCell.removePossible(possible)) {
              puzzle.sudoku.cellUpdated(otherCell, location,
                  "colour ${colourValue.name} impossible $otherCell");
              updated = true;
            }
          }
        }
      }
    }
    return updated;
  }

  Possible? getColourPossible(Cell cell) {
    for (var possible in colourPossible) {
      if (cell.possible.equals(possible)) return possible;
      if (cell.value != null && possible[cell.value!]) return possible;
    }
    return null;
  }

  ColourValue knownColourValue(Cell cell) {
    var value = ColourValue.UNKNOWN;
    if (cell.isSet) {
      value = mapValueToColourValue(cell.value!);
    } else {
      value = mapPossibleToColourValue(cell.possible);
    }
    return value;
  }

  ColourValue mapValueToColourValue(int value) {
    if (this.colours == 2) {
      if (value >= 1 && value <= 4) return ColourValue.LOW;
      if (value >= 6 && value <= 9) return ColourValue.HIGH;
      if (value == 5) ColourValue.MEDIUM;
    } else if (this.colours == 3) {
      if (value >= 1 && value <= 3) return ColourValue.LOW;
      if (value >= 4 && value <= 6) return ColourValue.MEDIUM;
      if (value >= 6 && value <= 9) return ColourValue.HIGH;
    }
    throw Exception;
  }

  ColourValue mapPossibleToColourValue(Possible possible) {
    var value = ColourValue.UNKNOWN;
    var valueCount = 0;
    if (this.colours == 2) {
      if (possible[1] || possible[2] || possible[3] || possible[4]) {
        valueCount++;
        value = ColourValue.LOW;
      }
      if (possible[5]) {
        valueCount++;
        value = ColourValue.MEDIUM;
      }
      if (possible[6] || possible[7] || possible[8] || possible[9]) {
        valueCount++;
        value = ColourValue.HIGH;
      }
      if (valueCount != 1) return ColourValue.UNKNOWN;
      return value;
    } else if (this.colours == 3) {
      if (possible[1] || possible[2] || possible[3]) {
        valueCount++;
        value = ColourValue.LOW;
      }
      if (possible[4] || possible[5] || possible[6]) {
        valueCount++;
        value = ColourValue.MEDIUM;
      }
      if (possible[7] || possible[8] || possible[9]) {
        valueCount++;
        value = ColourValue.HIGH;
      }
      if (valueCount != 1) return ColourValue.UNKNOWN;
      return value;
    }
    throw Exception;
  }
}
