import 'cell.dart';
import 'line.dart';
import 'lineRegion.dart';

class RegionSumRegion extends LineRegion {
  var segmentCells = <Cells>[];
  var boxes = <int>{};
  RegionSumRegion(Line renban, String name, Cells cells, {nodups = true})
      : super(renban, name, cells, nodups: nodups) {
    var box = 0;
    for (var cell in cells) {
      if (cell.box != box) {
        // New segment
        segmentCells.add([cell]);
        box = cell.box;
        boxes.add(box);
      } else {
        segmentCells.last.add(cell);
      }
    }
  }

  int validLineValues(List<int> values, Cells valueCells, Cells cells) {
    // Check for (partial) segment for cells
    var minimum = 0;
    var maximum = 45;
    var boxPossible = List.generate(
        9,
        (index) => boxes.contains(index + 1)
            ? List<int>.generate(9, (index) => index + 1)
            : <int>[]);
    for (var segment in segmentCells) {
      var possible = boxPossible[segment[0].box - 1];
      var total = 0;
      var unknown = 0;
      for (var cell in segment) {
        var index = valueCells.indexOf(cell);
        if (index != -1 && index < values.length) {
          var value = values[index];
          total += value;
          possible.remove(value);
        } else {
          unknown++;
        }
      }
      // Compute min.max for segment from known values and min/max possible for others
      var min = total +
          possible.take(unknown).fold<int>(
              0, (previousValue, element) => previousValue + element);
      var max = total +
          possible.reversed.take(unknown).fold<int>(
              0, (previousValue, element) => previousValue + element);
      // Check if segment is valid
      if (min > maximum) {
        if (segment.contains(valueCells[values.length - 1]))
          return 1; // continue
        return 1; // continue
      }
      if (minimum > max) return 1; // continue
      // Update region min/max for segment
      if (min > minimum) minimum = min;
      if (max < maximum) maximum = max;
    }
    return 0;
  }
}
