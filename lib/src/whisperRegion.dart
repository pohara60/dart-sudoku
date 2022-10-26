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
      validWhisperRegionValues, // Check Whisper values
    );
    return combinations;
  }

  int validWhisperRegionValues(List<int> values) {
    return validWhisperValues(values, this.cells, this.difference);
  }

  static int validWhisperValues(List<int> values, Cells cells, int difference) {
    // Check for whisper from prior cell
    if (values.length > 1) {
      var value = values[values.length - 1];
      var priorValue = values[values.length - 2];
      var diff = priorValue - value;
      if (diff < 0) diff = -diff;
      if (diff < difference) return 1; // continue
    }
    return 0;
  }

  static int validWhisperGroupValues(
      List<int> values, Cells cells, puzzle, List<Region>? regions) {
    var whisper = puzzle as Whisper;

    // Check whisper for cells in order
    var doneRegions = <WhisperRegion>[];
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      var cell = cells[valueIndex];
      var value = values[valueIndex];
      // Check whisper(s)
      for (var whisperRegion in whisper.getLines(cell).where((whisperRegion) =>
          !doneRegions.contains(whisperRegion) &&
          (regions == null || regions.contains(whisperRegion)))) {
        var index = whisperRegion.cells.indexOf(cell);
        assert(index != -1);
        var whisperValues = <int>[];
        whisperValues.add(value);
        // Check if other cells in whisper have values
        for (var priorValueIndex = valueIndex - 1;
            priorValueIndex >= 0;
            priorValueIndex--) {
          var priorCell = cells[priorValueIndex];
          var priorValue = values[priorValueIndex];
          var priorIndex = whisperRegion.cells.indexOf(priorCell);
          if (priorIndex != -1) {
            // In whisper
            whisperValues.add(priorValue);
          }
        }

        var result = validWhisperValues(
            whisperValues, whisperRegion.cells, whisperRegion.difference);
        if (result != 0) return result;

        doneRegions.add(whisperRegion);
      }
    }
    return 0;
  }
}
