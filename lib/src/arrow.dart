import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/arrowRegion.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/strategy/regionGroupCombinations.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Arrow extends PuzzleDecorator {
  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;
  List<RegionGroup> get regionGroups => sudoku.regionGroups;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Arrows are Regions of type ArrowRegion
  List<ArrowRegion> get arrows => List<ArrowRegion>.from(
      this.regions.where((region) => region.runtimeType == ArrowRegion));

  /// Get the first Arrow for a Cell
  ArrowRegion? getArrow(Cell cell) => cell.regions
          .firstWhereOrNull((region) => region.runtimeType == ArrowRegion)
      as ArrowRegion?;

  /// Get all Arrows for a Cell
  List<ArrowRegion> getArrows(Cell cell) => List<ArrowRegion>.from(
      cell.regions.where((region) => region.runtimeType == ArrowRegion));

  /// ArrowGroups are RegionGroups of type ArrowRegionGroup
  List<ArrowRegionGroup> get arrowGroups => List<ArrowRegionGroup>.from(this
      .regionGroups
      .where((region) => region.runtimeType == ArrowRegionGroup));

  late RegionCombinationsStrategy regionCombinationsStrategy;
  late RegionGroupCombinationsStrategy regionGroupCombinationsStrategy;

  void Function()? clearStateCallback = null;

  Arrow.puzzle(Puzzle puzzle, List<List<String>> arrowLines,
      [partial = false]) {
    puzzle.clearStateCallback = clearState;
    this.puzzle = puzzle;
    initArrow(arrowLines);
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
    //     .where((region) => region.value.runtimeType == ArrowRegion)
    //     .fold<String>(
    //         text, (text, region) => '$text\n${region.value.toString()}');
    String arrowChars(Cells cells, Cell cell) {
      var index = cells.indexOf(cell);
      if (index == 0) return '○';
      var prior = cells[index - 1];
      if (cell.row == prior.row) {
        if (index != cells.length - 1) return '-';
        if (cell.col > prior.col) return '→';
        return '←';
      }
      if (cell.col == prior.col) {
        if (index != cells.length - 1) return '|';
        if (cell.row > prior.row) return r'↓';
        return r'↑';
      }
      if (cell.row > prior.row) {
        if (cell.col > prior.col) {
          if (index != cells.length - 1) return r'⟍';
          return '↘';
        } else {
          if (index != cells.length - 1) return r'⟋';
          return '↙';
        }
      } else {
        if (cell.col > prior.col) {
          if (index != cells.length - 1) return r'⟋';
          return '↗';
        } else {
          if (index != cells.length - 1) return r'⟍';
          return '↖';
        }
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
                    (getArrow(cell) == null
                        ? colours[0]!(' ')
                        : colours[1]!(
                            arrowChars(getArrow(cell)!.cells, cell)))));
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
        toStr: stringFunc);
  }

  void initArrow(List<List<String>> arrowLines) {
    setArrow(arrowLines);
    if (sudoku.error) return;
    addRegionGroups();
  }

  var _arrowSeq = 1;

  void setArrow(List<List<String>> arrowLines) {
    for (var line in arrowLines) {
      var cells = sudoku.getLineCells(line);
      if (cells == null) return;

      var name = 'A${_arrowSeq++}';
      var nodups = cellsInNonet(cells);
      var region = ArrowRegion(this, name, cells, nodups: nodups);
      this.allRegions[name] = region;
    }
  }

  void addRegionGroups() {
    for (var axis in ['R', 'C', 'B']) {
      for (var major1 = 1; major1 < 10; major1++) {
        var cells = sudoku.getMajorAxis(axis, major1);
        var source = '$axis$major1';
        this.addRegionGroup(cells, source);
      }
    }
    if (sudoku.debug) {
      print(allRegions.entries
          .where((element) =>
              element.key.length > 2 && element.key.substring(0, 2) == 'AG')
          .map((e) => e.value)
          .join('\n'));
    }
  }

  var _arrowGroupSeq = 1;

  void addRegionGroup(Cells cells, String source) {
    var arrows = <ArrowRegion>[];
    var outieCells = <Cell>{};
    var groupCells = <Cell>{};
    for (var cell in cells) {
      for (var arrow in getArrows(cell)) {
        if (!arrows.contains(arrow)) {
          // Do not include arrow total in group
          var arrowCells = arrow.cells.sublist(1);
          var union =
              arrowCells.where((arrowCell) => cells.contains(arrowCell));
          // Union is empty if just arrow total
          if (union.isNotEmpty) {
            groupCells.addAll(union);
            var difference =
                arrowCells.where((arrowCell) => !cells.contains(arrowCell));
            outieCells.addAll(difference);
            arrows.add(arrow);
          }
        }
      }
    }
    // Do not add group for single arrow contained in cells
    if (arrows.isNotEmpty && arrows.length > 1) {
      // Now create all region groups, combination processing limits inefficiency
      // Do not bother when outies dominate
      // ignore: dead_code
      if (true || outieCells.length < groupCells.length) {
        var name = 'AG${_arrowGroupSeq++}';
        var cells = [...groupCells, ...outieCells];
        cells.sort((c1, c2) => c1.compareTo(c2));
        var nodups = cellsInNonet(cells);
        var group = ArrowRegionGroup(
          this,
          name,
          source,
          nodups,
          arrows,
          cells,
        );
        // Discard duplicates
        if (this
                .arrowGroups
                .firstWhereOrNull((arrowGroup) => arrowGroup.equals(group)) ==
            null) {
          this.allRegions[name] = group;
        } else
          _arrowGroupSeq--;
      }
    }
  }
}
