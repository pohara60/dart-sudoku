import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/domino.dart';
import 'package:sudoku/src/region.dart';

enum DominoType {
  DOMINO_X, // Add to 10
  DOMINO_V, // Add to 5
  DOMINO_C, // Consecutive
  DOMINO_M, // MUltiple 2
  DOMINO_O, // Odd parity
  DOMINO_E; // Even parity

  String toString() => this.name.substring(this.name.length - 1);
}

class DominoRegion extends Region<Domino> {
  final DominoType type;
  DominoRegion(Domino domino, String name, DominoType this.type, Cells cells,
      {nodups = true})
      : super(
          domino,
          name + type.toString(),
          type == DominoType.DOMINO_X
              ? 10
              : type == DominoType.DOMINO_V
                  ? 5
                  : 0,
          nodups,
          cells,
        ) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  Domino get domino => puzzle;

  toString() {
    var sortedCells = cells;
    var text = '$name:${sortedCells.cellsString()}';
    return text;
  }

  @override
  List<List<int>>? regionCombinations() {
    var combinations = nextRegionCombinations(
      0,
      this.total,
      <int>[],
      <String, List<int>>{},
      remainingOptionalTotal,
      validOptionalTotal,
      false, // unlimited
      validDominoValues,
    );
    return combinations;
  }

  int validDominoValues(List<int> values) {
    // Check Consecutive and Multiple, X/V checked by total logic
    if (type == DominoType.DOMINO_X && type == DominoType.DOMINO_V) return 0;

    // Check for domino from prior cell
    if (values.length < 2) return 0;

    var value = values[values.length - 1];
    var otherValue = values[values.length - 2];
    if (type == DominoType.DOMINO_C) {
      var diff = value - otherValue;
      if (diff < -1) return 1; // continue processing higher values
      if (diff > 1) return -1; // break processing higher values
      return 0;
    }
    if (type == DominoType.DOMINO_M) {
      if (value > otherValue) {
        var multiple = value ~/ otherValue;
        var remainder = value % otherValue;
        if (multiple < 2) return 1; // continue processing higher values
        if (multiple > 2 || remainder > 0)
          return -1; // break processing higher values
        return 0;
      } else {
        var multiple = otherValue ~/ value;
        var remainder = otherValue % value;
        if (multiple < 2) return 1; // continue processing higher values
        if (multiple > 2 || remainder > 0)
          return 1; // continue processing higher values
        return 0;
      }
    }
    if (type == DominoType.DOMINO_O) {
      var sum = value + otherValue;
      if (sum % 2 != 1) return 1; // continue processing higher values
      return 0;
    }
    if (type == DominoType.DOMINO_E) {
      var sum = value + otherValue;
      if (sum % 2 != 0) return 1; // continue processing higher values
      return 0;
    }
    return 0;
  }
}

class DominoRegionGroup extends RegionGroup {
  DominoRegionGroup(Domino puzzle, String name, String nonet, bool nodups,
      List<Region> regions, Cells cells)
      : super(puzzle, name, nonet, nodups, regions, cells);

  Domino get domino => puzzle;

  @override
  List<List<int>>? regionGroupCombinations(String explanation) {
    //print('$explanation not yet implemented!');
    //return null;
    // Get combinations while validating the (partial) dominos in the group
    // Limited to maximum
    var dominoCells = this.cells;
    var combinationCount = Limiter(COMBINATION_LIMIT);
    var iterationCount = Limiter(ITERATION_LIMIT);
    // var stopwatch = Stopwatch();
    // stopwatch.start();
    try {
      var dominoCombinations = cellCombinations(
        dominoCells,
        false,
        null,
        0,
        0,
        <int>[],
        <String, List<int>>{},
        remainingNoTotal,
        validNoTotal,
        combinationCount,
        iterationCount,
        validDominoGroupValues,
      );
      // stopwatch.stop();
      // print(
      //     'combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      // Get minimum total of dominoCombinations
      return dominoCombinations;
    } catch (e) {
      // stopwatch.stop();
      // print(
      //     'exception combinations=$combinationCount, iterations=$iterationCount, $this, elapsed=${stopwatch.elapsed}');
      return null;
    }
  }

  int validDominoGroupValues(List<int> values) {
    var cells = this.cells;

    // Check dominos for each cell that has a value
    // Recheck earlier cells in case a later cell is in earlier domino
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      var cell = cells[valueIndex];
      var value = values[valueIndex];
      // Check adjacent cells in the group that have a value
      var otherCells = domino.sudoku.adjacentCells(cell);
      for (var otherCell in otherCells) {
        var otherValueIndex = this.cells.indexOf(otherCell);
        if (otherValueIndex != -1 && otherValueIndex < values.length) {
          var otherValue = values[otherValueIndex];
          var dom = domino.sharedDomino(cell, otherCell);
          if (dom != null) {
            // Adjacent cell in domino, check valid
            var result = domino.validNeighbours(dom.type, value, otherValue);
            if (result != 0) return result;
          } else {
            // Adjacent cell not in domino, check negative constraint
            if (domino.negative) {
              if (domino.negativeNeighbours(value, otherValue)) {
                return 1; // continue processing higher values
              }
            }
          }
        }
      }
    }
    return 0;
  }
}
