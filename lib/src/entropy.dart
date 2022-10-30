import 'package:chalkdart/chalk.dart';
import 'cell.dart';
import 'entropyRegion.dart';
import 'line.dart';
import 'puzzle.dart';

class Entropy extends Line<EntropyRegion> {
  Entropy.puzzle(Puzzle puzzle, List<List<String>> entropyLines)
      : super.puzzle(puzzle, entropyLines);

  get lineColour => chalk.black.onYellow;

  get regionKey => 'E';

  EntropyRegion makeRegion(Line line, String name, Cells cells,
      {nodups = true, total = 0}) {
    return EntropyRegion(this, name, cells, nodups: nodups);
  }
}
