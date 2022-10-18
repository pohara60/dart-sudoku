import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/renbanRegion.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Renban extends PuzzleDecorator {
  late final bool partial;
  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Lines are Regions of type RenbanRegion
  List<RenbanRegion> get lines => List<RenbanRegion>.from(
      this.regions.where((region) => region.runtimeType == RenbanRegion));

  /// Get the first Line for a Cell
  RenbanRegion? getRenban(Cell cell) => cell.regions
          .firstWhereOrNull((region) => region.runtimeType == RenbanRegion)
      as RenbanRegion?;

  /// Get all Lines for a Cell
  List<RenbanRegion> getRenbans(Cell cell) => List<RenbanRegion>.from(
      cell.regions.where((region) => region.runtimeType == RenbanRegion));

  late RegionCombinationsStrategy regionCombinationsStrategy;

  Renban.puzzle(Puzzle puzzle, List<List<String>> renbanLines,
      [partial = false]) {
    this.puzzle = puzzle;
    this.partial = partial;
    initRenban(renbanLines);
    // Strategies
    regionCombinationsStrategy = RegionCombinationsStrategy(this);
  }

  static final colours = {
    0: chalk.black.onGrey,
    1: chalk.black.onMagenta,
  };

  String toString() {
    // text = regions.entries
    //     .where((region) => region.value.runtimeType == RenbanRegion)
    //     .fold<String>(
    //         text, (text, region) => '$text\n${region.value.toString()}');
    var text = sudoku.grid.fold<String>(
        '',
        (text, row) =>
            '$text' +
            (text != '' ? '\n' : '') +
            row.fold<String>(
                '',
                (text, cell) =>
                    text +
                    (getRenban(cell) == null
                        ? colours[0]!('  ')
                        : colours[1]!('  '))));
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
    var strategies = List<Strategy>.from(easyStrategies ?? []);
    if (!strategies.any(
        (strategy) => strategy.runtimeType == RegionCombinationsStrategy)) {
      strategies.add(regionCombinationsStrategy);
    }

    String stringFunc() => toStr == null ? toString() : toStr();

    return puzzle.solve(
        explain: explain,
        showPossible: showPossible,
        easyStrategies: strategies,
        toStr: stringFunc);
  }

  void initRenban(List<List<String>> renbanLines) {
    setRenban(renbanLines);
    if (sudoku.error) return;
  }

  var _lineSeq = 1;

  void setRenban(List<List<String>> renbanLines) {
    for (var line in renbanLines) {
      var cells = sudoku.getLineCells(line);
      if (cells == null) return;

      var name = 'RB${_lineSeq++}';
      var nodups = cellsInNonet(cells);
      var region = RenbanRegion(this, name, cells, nodups: nodups);
      this.allRegions[name] = region;
    }
  }
}
