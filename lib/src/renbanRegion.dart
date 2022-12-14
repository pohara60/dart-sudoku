import 'cell.dart';
import 'line.dart';
import 'lineRegion.dart';

class RenbanRegion extends LineRegion {
  RenbanRegion(Line renban, String name, Cells cells, {nodups = true})
      : super(renban, name, cells, nodups: nodups);

  int validLineValues(List<int> values, Cells valueCells, Cells cells) {
    // Check for renban from prior cells
    if (values.length > 1) {
      var minValue = 10;
      var maxValue = 0;
      for (var value in values) {
        if (value < minValue) minValue = value;
        if (value > maxValue) maxValue = value;
      }
      if (maxValue - minValue >= cells.length) return 1; // continue
      if (Set.from(values).length != values.length) return 1; // continue
    }
    return 0;
  }
}
