import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

import 'lineRegion.dart';
import 'strategy/regionGroupCombinations.dart';

abstract class Line<RegionType extends LineRegion> extends PuzzleDecorator {
  late final bool partial;
  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Lines are Regions of type LineRegion
  List<RegionType> get lines => List<RegionType>.from(
      this.regions.where((region) => region is RegionType));

  /// Get the first Line for a Cell
  RegionType? getLine(Cell cell) =>
      cell.regions.firstWhereOrNull((region) => region is RegionType)
          as RegionType?;

  /// Get all Lines for a Cell
  List<RegionType> getLines(Cell cell) => List<RegionType>.from(
      cell.regions.where((region) => region is RegionType));

  late RegionCombinationsStrategy regionCombinationsStrategy;
  late RegionGroupCombinationsStrategy regionGroupCombinationsStrategy;

  Line.puzzle(Puzzle puzzle, List<List<String>> lineLines, [partial = false]) {
    puzzle.clearStateCallback = clearState;
    this.puzzle = puzzle;
    this.partial = partial;
    initLine(lineLines);
    // Strategies
    regionCombinationsStrategy = RegionCombinationsStrategy(this);
    regionGroupCombinationsStrategy = RegionGroupCombinationsStrategy(this);
  }

  get defaultColour => chalk.black.onGrey;
  get lineColour => chalk.black.onWhite;

  String toString() {
    var text = sudoku.grid.fold<String>(
        '',
        (text, row) =>
            '$text' +
            (text != '' ? '\n' : '') +
            row.fold<String>(
                '',
                (text, cell) =>
                    text +
                    (getLine(cell) == null
                        ? defaultColour('  ')
                        : lineColour('  '))));
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
    List<Strategy> strategies = Strategy.addStrategies(
      easyStrategies,
      [regionCombinationsStrategy, regionGroupCombinationsStrategy],
    );

    String stringFunc() => toStr == null ? toString() : toStr();

    return puzzle.solve(
        explain: explain,
        showPossible: showPossible,
        easyStrategies: strategies,
        toughStrategies: toughStrategies,
        toStr: stringFunc);
  }

  void clearState() {
    for (var line in lines) {
      line.clearState();
    }
  }

  void initLine(List<List<String>> lineLines) {
    setLine(lineLines);
    if (sudoku.error) return;
  }

  var _lineSeq = 1;
  get regionKey => '';

  void setLine(List<List<String>> lineLines) {
    for (var line in lineLines) {
      var cells = sudoku.getLineCells(line);
      if (cells == null) return;

      var name = '$regionKey${_lineSeq++}';
      var nodups = cellsInNonet(cells);
      var region = makeRegion(this, name, cells, nodups: nodups);
      this.allRegions[name] = region;
    }
  }

  RegionType makeRegion(Line line, String name, Cells cells,
      {nodups = true, total = 0}) {
    throw UnimplementedError();
  }
}
