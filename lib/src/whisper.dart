import 'package:chalkdart/chalk.dart';
import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/whisperRegion.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/strategy/regionCombinations.dart';
import 'package:sudoku/src/strategy/strategy.dart';

import 'line.dart';

class Whisper extends Line<WhisperRegion> {
  Whisper.puzzle(Puzzle puzzle, List<List<String>> whisperLines)
      : super.puzzle(puzzle, whisperLines);

  get lineColour => chalk.black.onGreen;

  get regionKey => 'W';

  WhisperRegion makeRegion(Line line, String name, Cells cells,
      {nodups = true, total = 0}) {
    return WhisperRegion(this, name, cells, nodups: nodups);
  }
}
