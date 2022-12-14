import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';

abstract class Strategy {
  final Puzzle puzzle;
  late final Sudoku sudoku;
  final String explanation;
  Strategy(this.puzzle, this.explanation) {
    this.sudoku = puzzle.sudoku;
  }

  bool solve();

  static List<Strategy> addStrategies(
      List<Strategy>? oldStrategies, List<Strategy> addStrategies) {
    var strategies = List<Strategy>.from(oldStrategies ?? []);
    for (var strategy in addStrategies) {
      if (!strategies.any((s) => s.runtimeType == strategy.runtimeType)) {
        strategies.add(strategy);
      }
    }
    return strategies;
  }
}
