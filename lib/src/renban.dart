import 'package:chalkdart/chalk.dart';
import 'cell.dart';
import 'line.dart';
import 'puzzle.dart';
import 'renbanRegion.dart';

class Renban extends Line<RenbanRegion> {
  void Function()? clearStateCallback = null;
  Renban.puzzle(Puzzle puzzle, List<List<String>> renbanLines)
      : super.puzzle(puzzle, renbanLines) {
    puzzle.clearStateCallback = clearState;
  }

  get lineColour => chalk.black.onMagenta;

  get regionKey => 'RB';

  RenbanRegion makeRegion(Line line, String name, Cells cells,
      {nodups = true, total = 0}) {
    return RenbanRegion(this, name, cells, nodups: nodups);
  }
}
