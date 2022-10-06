import 'package:sudoku/src/cell.dart';
import 'package:sudoku/src/dominoRegion.dart';
import 'package:sudoku/src/puzzle.dart';
import 'package:sudoku/src/region.dart';
import 'package:sudoku/src/sudoku.dart';

import 'killerRegion.dart';

enum Parity {
  ODD,
  EVEN,
  UNKNOWN;

  String toString() {
    return this.name[0];
  }
}

class ParityRegion {
  Parity parity;
  final Region region;
  Cells? cells;
  late final List<ParityRegion> children;
  late final List<ParityRegion> parents;
  ParityRegion({
    this.parity = Parity.UNKNOWN,
    required this.region,
    this.cells = null,
    List<ParityRegion>? children,
    ParityRegion? parent,
  }) {
    this.children = children ?? [];
    this.parents = parent != null ? [parent] : [];
  }

  String get name => this.region.name;

  String toString() {
    return '${this.name}' +
        (this.cells != null ? ' ${this.cells!.cellsString()}' : '') +
        ' (' +
        this.children.fold<String>(
            '',
            ((previousValue, element) => previousValue != ''
                ? previousValue + ',${element.name}'
                : element.name)) +
        ') (' +
        this.parents.fold<String>(
            '',
            ((previousValue, element) => previousValue != ''
                ? previousValue + ',${element.name}'
                : element.name)) +
        ')';
  }

  static Map<Region, ParityRegion> getParityRegions(Puzzle puzzle) {
    var parityRegions = <Region, ParityRegion>{};
    var sudoku = puzzle.sudoku;
    addParityRegion(sudoku, parityRegions, sudoku.allRegions['G']!, null);
    // Process regions that do not fit in B/R/C
    for (var region in sudoku.regions) {
      if (!parityRegions.containsKey(region)) {
        addParityRegion(sudoku, parityRegions, region, null);
      }
    }
    return parityRegions;
  }

  static ParityRegion? addParityRegion(
      Sudoku sudoku,
      Map<Region, ParityRegion> parityRegions,
      Region<dynamic> region,
      ParityRegion? parent) {
    var parityRegion = parityRegions[region];
    if (parityRegion != null) {
      if (parent != null) parityRegion.parents.add(parent);
      return parityRegion;
    }

    if (region is SudokuRegion) {
      parityRegion =
          addSudokuParityRegion(sudoku, parityRegions, region, parent);
    } else if (region is DominoRegion &&
        (region.type == DominoType.DOMINO_E ||
            region.type == DominoType.DOMINO_O)) {
      parityRegion = ParityRegion(
        region: region,
        parity: region.type == DominoType.DOMINO_E ? Parity.EVEN : Parity.ODD,
        parent: parent,
      );
      parityRegions[region] = parityRegion;
    } else if (region is KillerRegion) {
      parityRegion =
          addKillerParityRegion(sudoku, parityRegions, region, parent);
    }
    return parityRegion;
  }

  static ParityRegion? addSudokuParityRegion(
      Sudoku sudoku,
      Map<Region, ParityRegion> parityRegions,
      SudokuRegion region,
      ParityRegion? parent) {
    var parityRegion = ParityRegion(
      region: region,
      parity: region.total % 2 == 0 ? Parity.EVEN : Parity.ODD,
      parent: parent,
    );
    parityRegions[region] = parityRegion;

    // Find regions included in this B/R/C
    var axis = region.name[0];
    var major = axis != 'G' ? int.parse(region.name[1]) : 0;
    var childParityRegions = <ParityRegion>[];
    var cells = Cells.from(region.cells);
    for (var childRegion in sudoku.allRegions.values.where((childRegion) =>
        childRegion != region &&
        (axis == 'G' && childRegion is SudokuRegion ||
            axis != 'G' &&
                !(childRegion is SudokuRegion) &&
                cellsInMajorAxis(childRegion.cells, axis, major)))) {
      var childParityRegion =
          addParityRegion(sudoku, parityRegions, childRegion, parityRegion);
      if (childParityRegion != null) {
        childParityRegions.add(childParityRegion);
        cells.removeWhere((cell) => childRegion.cells.contains(cell));
      }
    }
    parityRegion.children.addAll(childParityRegions);
    if (cells.isNotEmpty) parityRegion.cells = cells;

    return parityRegion;
  }

  static ParityRegion? addKillerParityRegion(
      Sudoku sudoku,
      Map<Region, ParityRegion> parityRegions,
      KillerRegion region,
      ParityRegion? parent) {
    // Only killer regions with known total are useful for parity
    if (region.total == 0) return null;

    var parityRegion = ParityRegion(
      region: region,
      parity: region.total % 2 == 0 ? Parity.EVEN : Parity.ODD,
      parent: parent,
    );
    parityRegions[region] = parityRegion;

    // Find regions included in this region
    var childParityRegions = <ParityRegion>[];
    var cells = Cells.from(region.cells);
    for (var childRegion in sudoku.allRegions.values.where((childRegion) =>
        childRegion != region &&
        cellsInCells(childRegion.cells, region.cells))) {
      var childParityRegion =
          addParityRegion(sudoku, parityRegions, childRegion, parityRegion);
      if (childParityRegion != null) {
        childParityRegions.add(childParityRegion);
        cells.removeWhere((cell) => childRegion.cells.contains(cell));
      }
    }
    parityRegion.children.addAll(childParityRegions);
    if (cells.isNotEmpty) parityRegion.cells = cells;

    return parityRegion;
  }
}
