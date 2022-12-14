import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/thermoRegion.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/strategy/regionGroupCombinations.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Thermo extends PuzzleDecorator {
  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;
  List<RegionGroup> get regionGroups => sudoku.regionGroups;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Thermos are Regions of type ThermoRegion
  List<ThermoRegion> get thermos => List<ThermoRegion>.from(
      this.regions.where((region) => region.runtimeType == ThermoRegion));

  /// Get the first Thermo for a Cell
  ThermoRegion? getThermo(Cell cell) => cell.regions
          .firstWhereOrNull((region) => region.runtimeType == ThermoRegion)
      as ThermoRegion?;

  /// Get all Thermos for a Cell
  List<ThermoRegion> getThermos(Cell cell) => List<ThermoRegion>.from(
      cell.regions.where((region) => region.runtimeType == ThermoRegion));

  /// ThermoGroups are RegionGroups of type ThermoRegionGroup
  List<ThermoRegionGroup> get thermoGroups => List<ThermoRegionGroup>.from(this
      .regionGroups
      .where((region) => region.runtimeType == ThermoRegionGroup));

  late RegionCombinationsStrategy regionCombinationsStrategy;
  late RegionGroupCombinationsStrategy regionGroupCombinationsStrategy;

  Thermo.puzzle(Puzzle puzzle, List<List<String>> thermoLines,
      [partial = false]) {
    this.puzzle = puzzle;
    initThermo(thermoLines);
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
    //     .where((region) => region.value.runtimeType == ThermoRegion)
    //     .fold<String>(
    //         text, (text, region) => '$text\n${region.value.toString()}');
    String thermoChars(Cells cells, Cell cell) {
      var index = cells.indexOf(cell);
      if (index == 0) return '○';
      var prior = cells[index - 1];
      if (cell.row == prior.row) return '-';
      if (cell.col == prior.col) return '|';
      if (cell.row > prior.row) {
        if (cell.col > prior.col)
          return r'⟍';
        else
          return r'⟋';
      } else {
        if (cell.col > prior.col)
          return r'⟍';
        else
          return r'⟋';
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
                    (getThermo(cell) == null
                        ? colours[0]!(' ')
                        : colours[1]!(
                            thermoChars(getThermo(cell)!.cells, cell)))));
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

  void initThermo(List<List<String>> thermoLines) {
    setThermo(thermoLines);
    if (sudoku.error) return;
    addRegionGroups();
  }

  var _thermoSeq = 1;

  void setThermo(List<List<String>> thermoLines) {
    for (var line in thermoLines) {
      var cells = sudoku.getLineCells(line);
      if (cells == null) return;

      var name = 'T${_thermoSeq++}';
      var region = ThermoRegion(this, name, cells);
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
  }

  var _thermoGroupSeq = 1;

  void addRegionGroup(Cells cells, source) {
    var thermos = <ThermoRegion>[];
    var outieCells = <Cell>{};
    var groupCells = <Cell>{};
    for (var cell in cells) {
      for (var thermo in getThermos(cell)) {
        if (!thermos.contains(thermo)) {
          var thermoCells = thermo.cells;
          var union =
              thermoCells.where((thermoCell) => cells.contains(thermoCell));
          groupCells.addAll(union);
          var difference =
              thermoCells.where((thermoCell) => !cells.contains(thermoCell));
          outieCells.addAll(difference);
          thermos.add(thermo);
        }
      }
    }
    // Do not add group for single thermo contained in cells
    if (thermos.isNotEmpty && thermos.length > 1) {
      // Now create all region groups, combination processing limits inefficiency
      // Do not bother when outies dominate
      // ignore: dead_code
      if (true || outieCells.length < groupCells.length) {
        var name = 'TG${_thermoGroupSeq++}';
        var cells = [...groupCells, ...outieCells];
        cells.sort((c1, c2) => c1.compareTo(c2));
        var nodups = cellsInNonet(cells);
        var group = ThermoRegionGroup(
          this,
          name,
          source,
          nodups,
          thermos,
          cells,
        );
        // Discard duplicates
        if (this
                .thermoGroups
                .firstWhereOrNull((thermoGroup) => thermoGroup.equals(group)) ==
            null) {
          this.allRegions[name] = group;
        } else
          _thermoGroupSeq--;
      }
    }
  }
}
