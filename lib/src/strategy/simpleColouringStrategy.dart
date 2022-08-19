import 'package:collection/collection.dart';
import 'package:sudoku/src/cell.dart';

import 'package:sudoku/src/sudoku.dart';
import 'package:sudoku/src/strategy/strategy.dart';

enum Colour {
  ODD,
  EVEN,
}

Colour toggleColour(Colour colour) =>
    colour == Colour.ODD ? Colour.EVEN : Colour.ODD;

class SimpleColouringStrategy extends Strategy {
  SimpleColouringStrategy(sudoku) : super(sudoku, 'Simple Colouring');

  bool solve() {
    var updated = false;

    var valuePossibleTwice = <String, Map<int, Map<int, List<int>>>>{};
    for (var axis in ['R', 'C', 'B']) {
      valuePossibleTwice[axis] = sudoku.getValuePossibleIndexes(axis, 2);
    }

    for (var value = 1; value < 10; value++) {
      // for axis
      var chains = <List<Cell>>[];
      var cellColour = <Cell, Colour>{};
      void addCellToChain(Cell cell, List<Cell> chain, Colour colour) {
        chain.add(cell);
        cellColour[cell] = colour;

        // For each axis for minors
        for (var axis in ['R', 'C', 'B']) {
          var valuePossibleTwiceValue = valuePossibleTwice[axis]![value];
          if (valuePossibleTwiceValue != null) {
            var major = cell.getAxis(axis);
            var minors = valuePossibleTwiceValue[major];
            if (minors != null) {
              for (var minor in minors) {
                var other = sudoku.getAxisCell(axis, major, minor);
                if (other != cell) {
                  // if cell not on a chain
                  // then recursively add to chain with alternate colour
                  // else merge chains, perhaps toggling its colours
                  var otherChain =
                      chains.firstWhereOrNull((chain) => chain.contains(other));
                  var nextColour = toggleColour(colour);
                  if (otherChain == null) {
                    addCellToChain(other, chain, nextColour);
                  } else if (otherChain != chain) {
                    var toggle = cellColour[other] != nextColour;
                    for (var chainCell in otherChain) {
                      chain.add(chainCell);
                      if (toggle) {
                        cellColour[chainCell] =
                            toggleColour(cellColour[chainCell]!);
                      }
                    }
                    chains.remove(otherChain);
                  }
                }
              }
            }
          }
        }
      }

      for (var axis in ['R', 'C', 'B']) {
        var valuePossibleTwiceValue = valuePossibleTwice[axis]![value];
        if (valuePossibleTwiceValue != null) {
          for (var major in valuePossibleTwiceValue.keys) {
            for (var minor in valuePossibleTwiceValue[major]!) {
              var cell = sudoku.getAxisCell(axis, major, minor);
              var colour = Colour.ODD;
              if (!chains.any((chain) => chain.contains(cell))) {
                // Create chain
                var chain = <Cell>[];
                chains.add(chain);
                // Add cell to chain with initial colour
                addCellToChain(cell, chain, colour);
              }
            }
          }
        }
      }

      // Debug
      // print('Singles Chains $value');
      // print(sudoku.toPossibleString());
      // for (var chain in chains) {
      //   print('Chain $chain');
      //   print('Colors ${chain.map((cell) => cellColour[cell].toString())}');
      // }

      // Rule 2
      // for axis
      for (var axis in ['R', 'C', 'B']) {
        // for major
        for (var major = 1; major < 10; major++) {
          // if two cells in axis on a chain have same colour
          // then fix chain to other colour
          var cells = sudoku.getMajorAxis(axis, major);
          var colours = <Colour?>[];
          var location = addExplanation(explanation, 'Rule 2 $axis$major');
          void fixChain(List<Cell> chain, Colour colour) {
            for (var cell in chain) {
              if (cellColour[cell] == colour) {
                if (cell.clearPossible(value)) {
                  updated = true;
                  sudoku.cellUpdated(
                      cell, location, "remove value $value from $cell");
                }
              } else {
                if (cell.value != value) {
                  cell.value = value;
                  updated = true;
                  sudoku.cellUpdated(cell, location, "set value $cell");
                }
              }
            }
          }

          for (var cell in cells) {
            var colour = cellColour[cell];
            if (colour != null) {
              // Check other cells in unit on same chain
              var chain = chains.firstWhere((chain) => chain.contains(cell));
              var otherCells = chain.where((c) =>
                  c != cell && cells.contains(c) && cellColour[c] == colour);
              if (otherCells.isNotEmpty) {
                fixChain(chain, colour);
              }
            }
          }
        }
      }
      // Rule 4
      // for each chain
      for (var chain in chains) {
        for (var index1 = 0; index1 < chain.length; index1++) {
          var cell1 = chain[index1];
          for (var index2 = index1 + 1; index2 < chain.length; index2++) {
            var cell2 = chain[index2];
            // for pairs of cells of different colour in different row and column
            if (cellColour[cell1] != cellColour[cell2] &&
                cell1.row != cell2.row &&
                cell1.col != cell2.col) {
              // check intersection cells to remove value
              for (var cell in [
                sudoku.getCell(cell1.row, cell2.col),
                sudoku.getCell(cell2.row, cell1.col)
              ]) {
                if (!chain.contains(cell)) {
                  var location = addExplanation(
                      explanation, 'Rule 4 ${cell1.name},${cell2.name}');
                  if (cell.clearPossible(value)) {
                    updated = true;
                    sudoku.cellUpdated(
                        cell, location, "remove value $value from $cell");
                  }
                }
              }
            }
          }
        }
      }
    }
    // if (cell.clearPossible(value)) {
    //   updated = true;
    //   sudoku.cellUpdated(cell, location, "remove value $value from $cell");
    // }
    return updated;
  }
}
