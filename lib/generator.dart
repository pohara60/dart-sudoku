class SudokuGenerator {
  static var nextSudokuPuzzle = 0;
  String newSudokuPuzzle() {
    var sudokuPuzzles = [
      //[ ".........", ".........", ".........", ".........", ".........", ".........", ".........", ".........", "........." ],
      // 4 Hidden Singles, 1 Pointing Group, then no logical steps!
      [
        "1...2....",
        ".6...852.",
        "28...97..",
        "...3...6.",
        ".5...69..",
        "....9..4.",
        "......6..",
        ".9.....57",
        "..6..7.89",
      ],
      // Swordfish
      [
        ".2..43.69",
        "..38962..",
        "96..25.3.",
        "89.56..13",
        "6...3....",
        ".3..81.26",
        "3...1..7.",
        "..96743.2",
        "27.358.9.",
      ],
      [
        "52941.7..",
        "..6..3..2",
        "..32.....",
        ".523...76",
        "637.5.2..",
        "19.62753.",
        "3...6942.",
        "2..83.6..",
        "96.7423.5",
      ],
      // Y-Wings
      [
        "9..24....",
        ".5.69.231",
        ".2..5..9.",
        ".9.7..32.",
        "..29356.7",
        ".7...29..",
        ".69.2..73",
        "51..79.62",
        "2.7.86..9"
      ],
      // X-Wings by column
      [
        ".......94",
        "76.91..5.",
        ".9...2.81",
        ".7..5..1.",
        "...7.9...",
        ".8..31.67",
        "24.1...7.",
        ".1..9..45",
        "9.....1.."
      ],
      // XWing by row
      [
        "1.....569",
        "492.561.8",
        ".561.924.",
        "..964.8.1",
        ".64.1....",
        "218.356.4",
        ".4.5...16",
        "9.5.614.2",
        "621.....5"
      ],
      // Pointing Group, YWing
      [
        ".16..78.3",
        ".9.8.....",
        "87...1.6.",
        ".48...3..",
        "65...9.82",
        ".39...65.",
        ".6.9...2.",
        ".8...2936",
        "9246..51.",
      ],
      [
        ".....123.",
        "123..8.4.",
        "8.4..765.",
        "765......",
        ".........",
        "......123",
        ".123..8.4",
        ".8.4..765",
        ".765.....",
      ],
      [
        "7...48...",
        ".5.....24",
        ".....9..1",
        ".2.....5.",
        "3.9.5...6",
        "...47..3.",
        "....1..4.",
        "18....69.",
        "2..7.....",
      ],
      [
        "7......4.",
        ".....827.",
        ".4.9.5...",
        "8.9..3...",
        "5.3...6.2",
        "...1..3.8",
        "...5.7.2.",
        ".564.....",
        ".9......3",
      ],
      [
        "...37....",
        "26.......",
        ".3.8...47",
        "9.3..7.1.",
        ".4.....3.",
        ".7.9..4.6",
        "51...2.7.",
        ".......21",
        "....18...",
      ],
      [
        "..4.5..2.",
        "3....97.6",
        "....78..3",
        ".15...8..",
        ".......5.",
        ".62...3..",
        "....17..5",
        "1....64.2",
        "..3.9..8.",
      ],
      [
        "...43....",
        "..9.2.8..",
        ".....7.29",
        ".5....1.3",
        "..62.57..",
        "8.1....6.",
        "14.9.....",
        "..2.6.9..",
        "....43...",
      ],
      [
        "....9....",
        "...2.7..6",
        "...6.571.",
        ".2756..4.",
        "5..3...2.",
        ".84...6..",
        "..9..3..5",
        "..572...3",
        ".3....268",
      ],
      [
        "...9...21",
        "....358..",
        "....1..5.",
        ".6......9",
        "..27.43..",
        "5......1.",
        ".1..2....",
        "..615....",
        "78...6...",
      ],
      [
        "5....39..",
        "....6....",
        "..21...75",
        "7.....34.",
        "...2.7...",
        ".86.....7",
        "97...65..",
        "....5....",
        "..58....2",
      ],
    ];
    if (nextSudokuPuzzle >= sudokuPuzzles.length) {
      nextSudokuPuzzle = 0;
    }
    var puzzle = sudokuPuzzles[nextSudokuPuzzle++].join('\n');
    return puzzle;
  }
}
