import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/dominoRegion.dart';
import 'package:sudoku/src/parityRegion.dart';
import 'package:sudoku/src/possible.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/strategy/regionGroupCombinations.dart';
import 'package:sudoku/src/strategy/updateDominoPossibleStrategy.dart';
import 'package:sudoku/src/strategy/updateParityStrategyy.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Domino extends PuzzleDecorator {
  late final bool negative; // Apply negative constraints
  final dominoTypes = <DominoType>{}; // Domino types for negative constraints
  Map<Region, ParityRegion>? parityRegions;

  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;
  List<RegionGroup> get regionGroups => sudoku.regionGroups;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Dominos are Regions of type DominoRegion
  List<DominoRegion> get dominos => List<DominoRegion>.from(
      this.regions.where((region) => region.runtimeType == DominoRegion));

  /// Get the first Domino for a Cell
  DominoRegion? getDomino(Cell cell) => cell.regions
          .firstWhereOrNull((region) => region.runtimeType == DominoRegion)
      as DominoRegion?;

  /// Get all Dominos for a Cell
  List<DominoRegion> getDominos(Cell cell) => List<DominoRegion>.from(
      cell.regions.where((region) => region.runtimeType == DominoRegion));

  /// DominoGroups are RegionGroups of type DominoRegionGroup
  List<DominoRegionGroup> get dominoGroups => List<DominoRegionGroup>.from(this
      .regionGroups
      .where((region) => region.runtimeType == DominoRegionGroup));

  late UpdateDominoPossibleStrategy updateDominoPossibleStrategy;
  late UpdateParityStrategy updateParityStrategy;
  late RegionCombinationsStrategy regionCombinationsStrategy;
  late RegionGroupCombinationsStrategy regionGroupCombinationsStrategy;

  Domino.puzzle(Puzzle puzzle, List<List<String>> dominoLines,
      [this.negative = false]) {
    this.puzzle = puzzle;
    initDomino(dominoLines);
    // Strategies
    updateDominoPossibleStrategy = UpdateDominoPossibleStrategy(this);
    updateParityStrategy = UpdateParityStrategy(this);
    regionCombinationsStrategy = RegionCombinationsStrategy(this);
    regionGroupCombinationsStrategy = RegionGroupCombinationsStrategy(this);
  }

  static final colours = {
    0: chalk.black.onWhite,
    1: chalk.black.onGrey,
  };

  String toString() {
    // text = regions.entries
    //     .where((region) => region.value.runtimeType == DominoRegion)
    //     .fold<String>(
    //         text, (text, region) => '$text\n${region.value.toString()}');

    String dominoRow(int rowIndex, Cells cells) {
      String rowStr = '';
      String nextStr = rowIndex < 8 ? '\n' : '';
      cells.forEachIndexed((colIndex, cell) {
        rowStr += colours[1]!('.');
        if (colIndex < 8) {
          var next = ' ';
          var d =
              sharedDomino(cell, sudoku.getCell(rowIndex + 1, colIndex + 2));
          if (d != null) next = d.type.toString();
          rowStr += colours[0]!(next);
        }
        if (rowIndex < 8) {
          var next = ' ';
          var d =
              sharedDomino(cell, sudoku.getCell(rowIndex + 2, colIndex + 1));
          if (d != null) next = d.type.toString();
          nextStr += colours[0]!(next);
          if (colIndex < 8) {
            nextStr += colours[0]!(' ');
          }
        }
      });
      return rowStr + nextStr;
    }

    var text = sudoku.grid.foldIndexed<String>(
        '',
        (index, text, row) =>
            '$text' + (text != '' ? '\n' : '') + dominoRow(index, row));
    text = '$text\n' + puzzle.toString();
    return text;
  }

  @override
  String solve(
      {bool explain = false,
      bool showPossible = false,
      List<Strategy>? easyStrategies,
      List<Strategy>? toughStrategies,
      Function? toStr}) {
    var strategies1 = List<Strategy>.from(easyStrategies ?? []);
    for (var strategy in [
      regionCombinationsStrategy,
      regionGroupCombinationsStrategy,
      updateParityStrategy,
    ]) {
      if (!strategies1.any((s) => s.runtimeType == strategy.runtimeType)) {
        strategies1.add(strategy);
      }
    }
    var strategies2 = List<Strategy>.from(easyStrategies ?? []);
    for (var strategy in [
      updateDominoPossibleStrategy,
    ]) {
      if (!strategies2.any((s) => s.runtimeType == strategy.runtimeType)) {
        strategies2.add(strategy);
      }
    }

    String stringFunc() => toStr == null ? toString() : toStr();

    return puzzle.solve(
        explain: explain,
        showPossible: showPossible,
        easyStrategies: strategies1,
        toughStrategies: strategies2,
        toStr: stringFunc);
  }

  void initDomino(List<List<String>> dominoLines) {
    setDomino(dominoLines);
    if (sudoku.error) return;
    addRegionGroups();
    if (sudoku.error) return;
    this.parityRegions = ParityRegion.getParityRegions(puzzle);
    print(parityRegions.toString().replaceAll(', ', '\n'));
  }

  var _dominoSeq = 1;

  void setDomino(List<List<String>> dominoLines) {
    var isRow = true;
    var row = 0;
    for (var line in dominoLines) {
      if (isRow) row++;
      bool isCol = true;
      var col = 0;
      for (var placeholder in line) {
        if (isCol) col++;
        if (isRow) {
          // Row line has dominos between columns
          if (isCol) {
            // Cell placeholder should be '.'
            if (placeholder != '.') {
              sudoku.addMessage(
                  'Cell placeholder $row,$col = $placeholder, should be .',
                  true);
            }
          } else {
            if (col >= 9) {
              sudoku.addMessage('Domino line $row is too long', true);
            }
            // Placeholder between columns
            if (placeholder != ' ') {
              addDomino(isRow, row, col, placeholder);
            }
          }
        } else {
          // Non-Row line has dominos between rows
          if (!isCol) {
            // Non-Cell placeholder should be ' '
            if (placeholder != ' ') {
              sudoku.addMessage(
                  'Non-Cell placeholder $row,$col = $placeholder, should be .',
                  true);
            }
          } else {
            if (row >= 9) {
              sudoku.addMessage('Redundant Domino line $row', true);
            }
            // Placeholder between rows
            if (placeholder != ' ') {
              addDomino(isRow, row, col, placeholder);
            }
          }
        }
        isCol = !isCol;
      }
      isRow = !isRow;
    }
  }

  void addDomino(bool isRow, int row, int col, String placeholder) {
    var cells = [sudoku.getCell(row, col)];
    if (isRow) cells.add(sudoku.getCell(row, col + 1));
    if (!isRow) cells.add(sudoku.getCell(row + 1, col));

    DominoType? type;
    switch (placeholder) {
      case 'X':
        type = DominoType.DOMINO_X;
        break;
      case 'V':
        type = DominoType.DOMINO_V;
        break;
      case 'C':
        type = DominoType.DOMINO_C;
        break;
      case 'M':
        type = DominoType.DOMINO_M;
        break;
      case 'O':
        type = DominoType.DOMINO_O;
        break;
      case 'E':
        type = DominoType.DOMINO_E;
        break;
      default:
        sudoku.addMessage(
            'Bad Domino placeholder $placeholder at $row,$col', true);
    }
    if (type != null) {
      var name = 'D${_dominoSeq++}';
      var region = DominoRegion(this, name, type, cells);
      this.allRegions[name] = region;
      this.dominoTypes.add(type);
    }
  }

  var _dominoGroupSeq = 1;

  void addRegionGroups() {
    void closure(DominoRegion domino, List<DominoRegion> groupDominos) {
      groupDominos.add(domino);
      for (var cell in domino.cells) {
        for (var otherDomino
            in getDominos(cell).where((element) => element != domino)) {
          if (!groupDominos.contains(otherDomino))
            closure(otherDomino, groupDominos);
        }
      }
    }

    var allGroupDominos = <DominoRegion>[];
    for (var domino in dominos) {
      if (allGroupDominos.contains(domino)) continue;

      var groupDominos = <DominoRegion>[];
      closure(domino, groupDominos);
      var groupCells = groupDominos.expand((e) => e.cells).toSet().toList();

      // Do not add group for single domino
      if (groupDominos.length > 1) {
        var name = 'DG${_dominoGroupSeq++}';
        groupCells.sort((c1, c2) => c1.compareTo(c2));
        var source = '';
        var nodups = cellsInNonet(groupCells);
        var group = DominoRegionGroup(
          this,
          name,
          source,
          nodups,
          groupDominos,
          groupCells,
        );
        // Discard duplicates (should not happen)
        if (this
                .dominoGroups
                .firstWhereOrNull((dominoGroup) => dominoGroup.equals(group)) ==
            null) {
          this.allRegions[name] = group;
        } else
          _dominoGroupSeq--;
      }
    }
  }

  DominoRegion? sharedDomino(Cell cell1, Cell cell2) {
    for (var d in getDominos(cell1)) {
      if (d.cells.contains(cell2)) return d;
    }
    return null;
  }

  Possible cellNeighbourImpossible(Cell cell) {
    var neighbour = Possible(true);
    for (var value = 1; value < 10; value++) {
      if (cell.isPossible(value)) {
        var impossible = valueNeighbourImpossible(value);
        neighbour = neighbour.intersect(impossible);
      }
    }
    return neighbour;
  }

  Possible valueNeighbourImpossible(int value) {
    var neighbour = Possible(false);
    // Include the value itself, as it is not possible for neighbour
    neighbour[value] = true;
    for (var otherValue = 1; otherValue < 10; otherValue++) {
      // Returning impossible values, i.e. not negative
      if (negativeNeighbours(value, otherValue)) neighbour[otherValue] = true;
    }
    return neighbour;
  }

  bool negativeNeighbours(int value, int otherValue) {
    for (var type in this.dominoTypes) {
      if (validNeighbours(type, value, otherValue) == 0) return true;
    }
    return false;
  }

  int validNeighbours(DominoType type, int value, int otherValue) {
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
