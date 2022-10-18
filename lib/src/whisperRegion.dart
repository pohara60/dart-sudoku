import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/whisper.dart';
import 'package:sudoku/src/region.dart';

class WhisperRegion extends Region<Whisper> {
  late Whisper whisper;
  int difference;

  WhisperRegion(Whisper whisper, String name, Cells cells,
      {nodups = true, this.difference = 5})
      : super(whisper, name, 0, nodups, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  toString() {
    var sortedCells = cells;
    var text = '$name:${sortedCells.cellsString()}';
    return text;
  }

  @override
  List<List<int>>? regionCombinations() {
    var combinations = nextRegionCombinations(
      0,
      0,
      <int>[],
      <String, List<int>>{},
      remainingNoTotal,
      validNoTotal,
      false, // Unlimited combinations
      validWhisperValues, // Check Whisper values
    );
    return combinations;
  }

  int validWhisperValues(List<int> values) {
    // Check for whisper from prior cell
    if (values.length > 1) {
      var value = values[values.length - 1];
      var priorValue = values[values.length - 2];
      var diff = priorValue - value;
      if (diff < 0) diff = -diff;
      if (diff < this.difference) return 1; // continue
    }
    return 0;
  }
}
