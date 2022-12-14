import 'cell.dart';
import 'lineRegion.dart';
import 'whisper.dart';

class WhisperRegion extends LineRegion {
  int difference;

  WhisperRegion(Whisper whisper, String name, Cells cells,
      {nodups = true, this.difference = 5})
      : super(whisper, name, cells, nodups: nodups);

  int validLineValues(List<int> values, Cells valueCells, Cells cells) {
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
}
