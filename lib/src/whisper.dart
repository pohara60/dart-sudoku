import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/whisperRegion.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Whisper extends PuzzleDecorator {
  late final bool partial;
  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  /// Lines are Regions of type WhisperRegion
  List<WhisperRegion> get lines => List<WhisperRegion>.from(
      this.regions.where((region) => region.runtimeType == WhisperRegion));

  /// Get the first Line for a Cell
  WhisperRegion? getLine(Cell cell) => cell.regions
          .firstWhereOrNull((region) => region.runtimeType == WhisperRegion)
      as WhisperRegion?;

  /// Get all Lines for a Cell
  List<WhisperRegion> getLines(Cell cell) => List<WhisperRegion>.from(
      cell.regions.where((region) => region.runtimeType == WhisperRegion));

  late RegionCombinationsStrategy regionCombinationsStrategy;

  Whisper.puzzle(Puzzle puzzle, List<List<String>> whisperLines,
      [partial = false]) {
    this.puzzle = puzzle;
    this.partial = partial;
    initWhisper(whisperLines);
    // Strategies
    regionCombinationsStrategy = RegionCombinationsStrategy(this);
  }

  static final colours = {
    0: chalk.black.onGrey,
    1: chalk.black.onGreen,
  };

  String toString() {
    // text = regions.entries
    //     .where((region) => region.value.runtimeType == WhisperRegion)
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
                    (getLine(cell) == null
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

  void initWhisper(List<List<String>> whisperLines) {
    setWhisper(whisperLines);
    if (sudoku.error) return;
  }

  static var _lineSeq = 1;

  void setWhisper(List<List<String>> whisperLines) {
    var badCells = '';
    for (var line in whisperLines) {
      var cells = <Cell>[];
      Cell? priorCell;
      for (var location in line) {
        assert(location.length == 4);
        var row = int.tryParse(location[1]);
        var col = int.tryParse(location[3]);
        if (row == null ||
            col == null ||
            row < 1 ||
            row > 9 ||
            col < 1 ||
            col > 9) {
          badCells = badCells == '' ? location : '$badCells,$location';
          priorCell = null;
        } else {
          var cell = sudoku.getCell(row, col);
          if (priorCell != null && !priorCell.adjacent(cell)) {
            sudoku.addMessage('Non-adjacent Whisper cells $line', true);
          }
          cells.add(cell);
          priorCell = cell;
        }
      }
      var name = 'W${_lineSeq++}';
      var nodups = cellsInNonet(cells);
      var region = WhisperRegion(this, name, cells, nodups: nodups);
      this.allRegions[name] = region;
    }

    if (badCells != '') {
      sudoku.addMessage('Could not process Whisper cells $badCells', true);
      return;
    }
  }
}
