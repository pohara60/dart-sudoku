import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/entropyRegion.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Entropy extends PuzzleDecorator {
  late final bool partial;
  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Lines are Regions of type EntropyRegion
  List<EntropyRegion> get lines => List<EntropyRegion>.from(
      this.regions.where((region) => region.runtimeType == EntropyRegion));

  /// Get the first Line for a Cell
  EntropyRegion? getEntropy(Cell cell) => cell.regions
          .firstWhereOrNull((region) => region.runtimeType == EntropyRegion)
      as EntropyRegion?;

  /// Get all Lines for a Cell
  List<EntropyRegion> getEntropys(Cell cell) => List<EntropyRegion>.from(
      cell.regions.where((region) => region.runtimeType == EntropyRegion));

  late RegionCombinationsStrategy regionCombinationsStrategy;

  Entropy.puzzle(Puzzle puzzle, List<List<String>> entropyLines,
      [partial = false]) {
    this.puzzle = puzzle;
    this.partial = partial;
    initEntropy(entropyLines);
    // Strategies
    regionCombinationsStrategy = RegionCombinationsStrategy(this);
  }

  static final colours = {
    0: chalk.black.onGrey,
    1: chalk.black.onYellow,
  };

  String toString() {
    // text = regions.entries
    //     .where((region) => region.value.runtimeType == EntropyRegion)
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
                    (getEntropy(cell) == null
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

  void initEntropy(List<List<String>> entropyLines) {
    setEntropy(entropyLines);
    if (sudoku.error) return;
  }

  var _lineSeq = 1;

  void setEntropy(List<List<String>> entropyLines) {
    for (var line in entropyLines) {
      var cells = sudoku.getLineCells(line);
      if (cells == null) return;

      var name = 'E${_lineSeq++}';
      var nodups = cellsInNonet(cells);
      var region = EntropyRegion(this, name, cells, nodups: nodups);
      this.allRegions[name] = region;
    }
  }
}
