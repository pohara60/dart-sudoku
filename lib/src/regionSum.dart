import 'package:chalkdart/chalk.dart';
import 'cell.dart';
import 'line.dart';
import 'puzzle.dart';
import 'regionSumRegion.dart';

class RegionSum extends Line<RegionSumRegion> {
  RegionSum.puzzle(Puzzle puzzle, List<List<String>> regionSumLines)
      : super.puzzle(puzzle, regionSumLines);

  get lineColour => chalk.black.onCyan;

  get regionKey => 'RS';

  RegionSumRegion makeRegion(Line line, String name, Cells cells,
      {nodups = true, total = 0}) {
    return RegionSumRegion(this, name, cells, nodups: nodups);
  }
}
