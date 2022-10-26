import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/entropy.dart';
import 'package:sudoku/src/region.dart';

class EntropyRegion extends Region<Entropy> {
  late Entropy entropy;
  int difference;

  EntropyRegion(Entropy entropy, String name, Cells cells,
      {nodups = true, this.difference = 5})
      : super(entropy, name, 0, nodups, cells) {
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
      validEntropyRegionValues, // Check Entropy values
    );
    return combinations;
  }

  int validEntropyRegionValues(List<int> values) {
    return validEntropyValues(values, this.cells);
  }

  static int validEntropyValues(List<int> values, Cells cells) {
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

  static int validEntropyGroupValues(
      List<int> values, Cells cells, puzzle, List<Region>? regions) {
    var entropy = puzzle as Entropy;

    // Check entropy for cells in order
    var doneRegions = <EntropyRegion>[];
    for (var valueIndex = values.length - 1; valueIndex >= 0; valueIndex--) {
      var cell = cells[valueIndex];
      var value = values[valueIndex];
      // Check entropy(s)
      for (var entropyRegion in entropy.getEntropys(cell).where(
          (entropyRegion) =>
              !doneRegions.contains(entropyRegion) &&
              (regions == null || regions.contains(entropyRegion)))) {
        var index = entropyRegion.cells.indexOf(cell);
        assert(index != -1);
        var entropyValues = <int>[];
        entropyValues.add(value);
        // Check if other cells in entropy have values
        for (var priorValueIndex = valueIndex - 1;
            priorValueIndex >= 0;
            priorValueIndex--) {
          var priorCell = cells[priorValueIndex];
          var priorValue = values[priorValueIndex];
          var priorIndex = entropyRegion.cells.indexOf(priorCell);
          if (priorIndex != -1) {
            // In entropy
            entropyValues.add(priorValue);
          }
        }

        var result = validEntropyValues(entropyValues, entropyRegion.cells);
        if (result != 0) return result;

        doneRegions.add(entropyRegion);
      }
    }
    return 0;
  }
}
