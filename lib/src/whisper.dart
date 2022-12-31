import 'package:chalkdart/chalk.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/whisperRegion.dart';
import 'package:sudoku/src/puzzle.dart';

import 'line.dart';
import 'strategy/regionColouringStrategy.dart';
import 'strategy/strategy.dart';

class Whisper extends Line<WhisperRegion> {
  late RegionColouringStrategy regionColouringStrategy;

  void Function()? clearStateCallback = null;

  Whisper.puzzle(Puzzle puzzle, List<List<String>> whisperLines)
      : super.puzzle(puzzle, whisperLines) {
    puzzle.clearStateCallback = clearState;
    // Strategies
    regionColouringStrategy = RegionColouringStrategy(this);
  }

  get lineColour => chalk.black.onGreen;

  get regionKey => 'W';

  WhisperRegion makeRegion(Line line, String name, Cells cells,
      {nodups = true, total = 0}) {
    return WhisperRegion(this, name, cells, nodups: nodups);
  }

  @override
  String solve(
      {bool explain = false,
      bool showPossible = false,
      List<Strategy>? easyStrategies,
      List<Strategy>? toughStrategies,
      Function? toStr}) {
    var strategies = Strategy.addStrategies(toughStrategies, [
      regionColouringStrategy,
    ]);

    String stringFunc() => toStr == null ? toString() : toStr();

    return super.solve(
        explain: explain,
        showPossible: showPossible,
        easyStrategies: strategies,
        toughStrategies: toughStrategies,
        toStr: stringFunc);
  }
}
