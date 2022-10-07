import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/sandwich.dart';
import 'package:sudoku/src/region.dart';

class SandwichRegion extends Region<Sandwich> {
  SandwichRegion(Sandwich sandwich, String name, int total, Cells cells)
      : super(sandwich, name, total, true, cells) {
    for (var cell in cells) {
      cell.regions.add(this);
    }
  }

  Sandwich get sandwich => puzzle;

  toString() {
    var sortedCells = cells;
    var text = '$name $total:${sortedCells.cellsString()}';
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
      true, // limited
      validSandwichValues,
    );
    return combinations;
  }

  int validSandwichValues(List<int> values) {
    var inSandwich = false;
    var innieTotal = 0;
    var priorInnie = 0;
    var outieTotal = 0;

    for (var value in values) {
      if (value == 1 || value == 9) {
        inSandwich = !inSandwich;
      } else {
        if (inSandwich) {
          priorInnie = innieTotal;
          innieTotal += value;
        } else
          outieTotal += value;
      }
    }
    if (innieTotal > this.total && priorInnie == this.total)
      return 1; // continue processing higher values to get 9
    if (innieTotal > this.total) return -1; // break processing higher values
    if (outieTotal > 45 - 10 - this.total)
      return 1; // continue processing higher values to get 9
    if (innieTotal > 0 && !inSandwich && innieTotal < this.total)
      return 1; // continue processing higher values
    return 0;
  }
}
