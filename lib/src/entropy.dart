import 'package:chalkdart/chalk.dart';
import 'cell.dart';
import 'entropyRegion.dart';
import 'line.dart';
import 'puzzle.dart';
import 'strategy/regionColouringStrategy.dart';
import 'strategy/strategy.dart';

class Entropy extends Line<EntropyRegion> {
  late RegionColouringStrategy regionColouringStrategy;
  void Function()? clearStateCallback = null;

  Entropy.puzzle(Puzzle puzzle, List<List<String>> entropyLines)
      : super.puzzle(puzzle, entropyLines) {
    puzzle.clearStateCallback = clearState;
    // Strategies
    regionColouringStrategy = RegionColouringStrategy(this);
  }

  get lineColour => chalk.black.onYellow;

  get regionKey => 'E';

  EntropyRegion makeRegion(Line line, String name, Cells cells,
      {nodups = true, total = 0}) {
    return EntropyRegion(this, name, cells, nodups: nodups);
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
