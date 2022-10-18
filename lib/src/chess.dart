import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/strategy/updateChessPossibleStrategy.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

class Chess extends PuzzleDecorator {
  final bool kingsMove;
  final bool knightsMove;

  Map<String, Region> get allRegions => sudoku.allRegions;
  List<Region> get regions => sudoku.regions;

  Sudoku get sudoku => puzzle.sudoku;
  String get messageString => sudoku.messageString;

  late UpdateChessPossibleStrategy updateChessPossibleStrategy;

  Chess.puzzle(Puzzle puzzle,
      {this.kingsMove = false, this.knightsMove = false}) {
    this.puzzle = puzzle;
    // Strategies
    updateChessPossibleStrategy = UpdateChessPossibleStrategy(this);
  }

  String toString() {
    var text =
        'Chess ${kingsMove ? "Kings Move " : ""}${knightsMove ? "Knights Move " : ""}';
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
        (strategy) => strategy.runtimeType == UpdateChessPossibleStrategy)) {
      strategies.add(updateChessPossibleStrategy);
    }

    String stringFunc() => toStr == null ? toString() : toStr();

    return puzzle.solve(
        explain: explain,
        showPossible: showPossible,
        easyStrategies: strategies,
        toStr: stringFunc);
  }
}
