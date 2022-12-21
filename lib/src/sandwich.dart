import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/sandwichRegion.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/strategy/regionGroupCombinations.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Sandwich extends PuzzleDecorator {
  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;
  List<RegionGroup> get regionGroups => sudoku.regionGroups;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Sandwichs are Regions of type SandwichRegion
  List<SandwichRegion> get sandwichs => List<SandwichRegion>.from(
      this.regions.where((region) => region.runtimeType == SandwichRegion));

  /// Get the first Sandwich for a Cell
  SandwichRegion? getSandwich(Cell cell) => cell.regions
          .firstWhereOrNull((region) => region.runtimeType == SandwichRegion)
      as SandwichRegion?;

  /// Get all Sandwichs for a Cell
  List<SandwichRegion> getSandwichs(Cell cell) => List<SandwichRegion>.from(
      cell.regions.where((region) => region.runtimeType == SandwichRegion));

  late RegionCombinationsStrategy regionCombinationsStrategy;
  late RegionGroupCombinationsStrategy regionGroupCombinationsStrategy;
  void Function()? clearStateCallback = null;

  Sandwich.puzzle(Puzzle puzzle, List<List<dynamic>> sandwichLines,
      [partial = false]) {
    puzzle.clearStateCallback = clearState;
    this.puzzle = puzzle;
    initSandwich(sandwichLines);
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
    //     .where((region) => region.value.runtimeType == SandwichRegion)
    //     .fold<String>(
    //         text, (text, region) => '$text\n${region.value.toString()}');
    var columnString =
        [1, 2, 3, 4, 5, 6, 7, 8, 9].fold<String>('', (previousValue, c) {
      var s = sudoku.allRegions['SC$c'];
      return previousValue + (s != null ? s.total.toString().padLeft(2) : '  ');
    });
    var text = columnString;
    for (var r = 1; r < 10; r++) {
      var s = sudoku.allRegions['SR$r'];
      text += '\n';
      text += (s != null ? s.total.toString().padLeft(2) : '  ');
      text += ' . . . . . . . . .';
    }

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

  void initSandwich(List<List<dynamic>> sandwichLines) {
    setSandwich(sandwichLines);
    if (sudoku.error) return;
  }

  void setSandwich(List<List<dynamic>> sandwichLines) {
    for (var line in sandwichLines) {
      if (line.length != 2 || line[0].length != 2) {
        sudoku.addMessage('Bad sandwich spec $line', true);
        continue;
      }
      var region = sudoku.allRegions[line[0]];
      var total = line[1];
      if (region == null || !(total is int) || total < 2 || total > 35) {
        sudoku.addMessage('Invalid sandwich spec $line', true);
        return null;
      }
      // Copy name and cells from Sudoku Region
      var cells = region.cells;
      var name = 'S' + region.name;
      region = SandwichRegion(this, name, total, cells);
      this.allRegions[name] = region;
    }
  }
}
