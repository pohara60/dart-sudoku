import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/littleKillerRegion.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/strategy/regionGroupCombinations.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class LittleKiller extends PuzzleDecorator {
  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;
  List<RegionGroup> get regionGroups => sudoku.regionGroups;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// LittleKillers are Regions of type LittleKillerRegion
  List<LittleKillerRegion> get littleKillers => List<LittleKillerRegion>.from(
      this.regions.where((region) => region.runtimeType == LittleKillerRegion));

  /// Get the first LittleKiller for a Cell
  LittleKillerRegion? getLittleKiller(Cell cell) =>
      cell.regions.firstWhereOrNull(
              (region) => region.runtimeType == LittleKillerRegion)
          as LittleKillerRegion?;

  /// Get all LittleKillers for a Cell
  List<LittleKillerRegion> getLittleKillers(Cell cell) =>
      List<LittleKillerRegion>.from(cell.regions
          .where((region) => region.runtimeType == LittleKillerRegion));

  /// LittleKillerGroups are RegionGroups of type LittleKillerRegionGroup
  List<LittleKillerRegionGroup> get littleKillerGroups =>
      List<LittleKillerRegionGroup>.from(this
          .regionGroups
          .where((region) => region.runtimeType == LittleKillerRegionGroup));

  late RegionCombinationsStrategy regionCombinationsStrategy;
  late RegionGroupCombinationsStrategy regionGroupCombinationsStrategy;

  void Function()? clearStateCallback = null;

  LittleKiller.puzzle(Puzzle puzzle, List<List<String>> littleKillerLines,
      [partial = false]) {
    puzzle.clearStateCallback = clearState;
    this.puzzle = puzzle;
    initLittleKiller(littleKillerLines);
    // Strategies
    regionCombinationsStrategy = RegionCombinationsStrategy(this);
    regionGroupCombinationsStrategy = RegionGroupCombinationsStrategy(this);
  }

  static final colours = {
    0: chalk.black.onWhite,
    1: chalk.black.onGrey,
  };

  String toString() {
    // text = regions.entries
    //     .where((region) => region.value.runtimeType == LittleKillerRegion)
    //     .fold<String>(
    //         text, (text, region) => '$text\n${region.value.toString()}');
    String littleKillerChars(Cells cells, Cell cell) {
      var index = cells.indexOf(cell);
      if (index == 0) return '○';
      var prior = cells[index - 1];
      if (cell.row > prior.row) {
        if (cell.col > prior.col)
          return r'⟍';
        else
          return r'⟋';
      } else {
        if (cell.col > prior.col)
          return r'⟋';
        else
          return r'⟍';
      }
    }

    var text = sudoku.grid.fold<String>(
        '',
        (text, row) =>
            '$text' +
            (text != '' ? '\n' : '') +
            row.fold<String>(
                '',
                (text, cell) =>
                    text +
                    (getLittleKiller(cell) == null
                        ? colours[0]!(' ')
                        : colours[1]!(littleKillerChars(
                            getLittleKiller(cell)!.cells, cell)))));
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
    var strategies = Strategy.addStrategies(easyStrategies, [
      regionCombinationsStrategy,
      regionGroupCombinationsStrategy,
    ]);

    String stringFunc() => toStr == null ? toString() : toStr();

    return puzzle.solve(
        explain: explain,
        showPossible: showPossible,
        easyStrategies: strategies,
        toughStrategies: toughStrategies,
        toStr: stringFunc);
  }

  void initLittleKiller(List<List<String>> littleKillerLines) {
    setLittleKiller(littleKillerLines);
    if (sudoku.error) return;
  }

  var _littleKillerSeq = 1;

  static const DIRECTION_UL = 'UL';
  static const DIRECTION_UR = 'UR';
  static const DIRECTION_DL = 'DL';
  static const DIRECTION_DR = 'DR';
  static const DIRECTIONS = [
    DIRECTION_UL,
    DIRECTION_UR,
    DIRECTION_DL,
    DIRECTION_DR,
  ];

  void setLittleKiller(List<List<String>> littleKillerLines) {
    for (var line in littleKillerLines) {
      // First entry is sum
      if (line.length < 1 || int.tryParse(line[0]) == null) {
        sudoku.addMessage('Missing little killer sum', true);
        return;
      }
      var sum = int.parse(line[0]);

      // Second entry is direction
      if (line.length < 2 || !DIRECTIONS.contains(line[1])) {
        sudoku.addMessage(
            'Missing little killer direction, or should be one of $DIRECTIONS',
            true);
        return;
      }
      var direction = line[1];

      if (line.length != 3) {
        sudoku.addMessage(
            'Little killer should have exactly one starting cell', true);
        return;
      }

      var cells = sudoku.getLineCells(line.slice(2));
      if (cells == null) return;

      // Add other cells
      var row = cells[0].row;
      var col = cells[0].col;
      while (true) {
        if (direction == DIRECTION_UL) {
          row--;
          col--;
        }
        if (direction == DIRECTION_UR) {
          row--;
          col++;
        }
        if (direction == DIRECTION_DL) {
          row++;
          col--;
        }
        if (direction == DIRECTION_DR) {
          row++;
          col++;
        }
        if (row < 1 || row > 9 || col < 1 || col > 9) break;
        var cell = sudoku.getCell(row, col);
        cells.add(cell);
      }

      var name = 'LK${_littleKillerSeq++}';
      var nodups = cellsInNonet(cells);
      var region =
          LittleKillerRegion(this, name, sum, direction, cells, nodups: nodups);
      this.allRegions[name] = region;
    }
  }
}
