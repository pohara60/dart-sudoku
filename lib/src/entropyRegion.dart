import 'cell.dart';
import 'entropy.dart';
import 'lineRegion.dart';

class EntropyRegion extends LineRegion {
  late Entropy entropy;
  int difference;

  EntropyRegion(Entropy entropy, String name, Cells cells,
      {nodups = true, this.difference = 5})
      : super(entropy, name, cells, nodups: nodups);

  int validLineValues(List<int> values, Cells valueCells, Cells cells) {
    // Check for entropy from prior cells
    var entropy = List.filled(3, -1);
    for (var i = 0; i < values.length; i++) {
      var value = values[i];
      var e = (value - 1) ~/ 3;
      if (i < 3) {
        for (var j = 0; j < i; j++) {
          if (entropy[j] == e) {
            // repeated entropy
            if (e == 2) return -1; // break
            return 1; // continue
          }
        }
        entropy[i] = e;
        continue;
      }
      if (entropy[i % 3] != e) {
        // incorrect entropy
        if (e == 2) return -1; // break
        return 1; // continue
      }
    }
    return 0;
  }
}
