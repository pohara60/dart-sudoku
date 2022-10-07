# dart-dudoku

Dart Sudoku solver package, with Command Line Interface.

## To Do

1. Support Circle constraints (intersections define possible neighbours)
2. Change iteration strategy to try common value
3. Change Region Group creation to focus on intersections?
4. Cache Region combinations to limit next computation?
5. Support Renban constraints
6. Support Sandwich constraints
7. Support 159 constraints
8. Support Little Killer constraints
9. Support Circle (even) and Square (Odd) constraints
10. Support Knight-move and King-move constraints
11. Support Palindrome constraints
12. Add efficient Brute force solvers
13. Add Diabolical Strategies
14. Add Extreme Strategies

## Sandwich Outstanding

Need Mixed Region Group to check valid values with intersecting (Domino) regions

## Parity Outstanding

Run of Odd parity dominos (DominoRegionGroup), in row, e.g. r3c2/8 E

## Strategies

[Strategies](https.//www.sudokuwiki.org/Strategy_Families)

Show Possibles
Check for Solved Squares

### Easy Strategies

1. [x] [Hidden Singles](https.//www.sudokuwiki.org/Getting_Started)
2. [x] [Naked Pairs/Triples](https.//www.sudokuwiki.org/Naked_Candidates#NP)
3. [x] [Hidden Pairs/Triples](https://www.sudokuwiki.org/Hidden_Candidates#HP)
4. [x] [Quads](https://www.sudokuwiki.org/Naked_Candidates#NQ)
5. [x] [Killer Combinations (easy)](https://www.sudokuwiki.org/Killer_Combinations)
       Killer Combinatiosn does easy and hard
6. [x] [Killer Innies and Outies (1 cell)](https://www.sudokuwiki.org/Innies_And_Outies)
       Innies and Outies are handled by "virtual" cages created at killer initialisation
7. [x] [Pointing Pairs](https://www.sudokuwiki.org/Intersection_Removal#IR)
8. [x] [Box/Line Reduction](https://www.sudokuwiki.org/Intersection_Removal#LBR)

### Tough Strategies

9. [x] [Killer Cage Splitting](https://www.sudokuwiki.org/Cage_Splitting)
       Handled by virtual cages
10. [x] [X-Wing](https://www.sudokuwiki.org/X_Wing_Strategy)
11. [x] [Simple Colouring](https://www.sudokuwiki.org/Singles_Chains)
12. [x] [Y-Wing](https://www.sudokuwiki.org/Y_Wing_Strategy)
13. [x] [Killer Innies/Outies (2+ cells)](https://www.sudokuwiki.org/Innies_And_Outies)
14. [x] [Killer Combo's (hard)](https://www.sudokuwiki.org/Killer_Combinations)
15. [x] [Killer Cage/Unit Overlap](https://www.sudokuwiki.org/Cage_Unit_Overlap)
        Line Box Reduction updates overlapping Cages
16. [ ] [Killer Cage Compare](https://www.sudokuwiki.org/Cage_Comparison)
17. [x] [Swordfish](https://www.sudokuwiki.org/Sword_Fish_Strategy)
18. [x] [XYZ Wing](https://www.sudokuwiki.org/XYZ_Wing)

### Diabolical Strategies

19. [ ] [X-Cycles](https://www.sudokuwiki.org/X_Cycles)
20. [ ] [XY-Chain](https://www.sudokuwiki.org/XY_Chains)
21. [ ] [3D Medusa](https://www.sudokuwiki.org/3D_Medusa)
22. [ ] [Jellyfish](https://www.sudokuwiki.org/Jelly_Fish_Strategy)
23. [ ] [WXYZ Wing](https://www.sudokuwiki.org/WXYZ_Wing)
24. [ ] [Aligned Pair Exclusion](https://www.sudokuwiki.org/Aligned_Pair_Exclusion)

### Extreme Strategies

25. [ ] [Grouped X-Cycles](https://www.sudokuwiki.org/Grouped_X_Cycles)
26. [ ] [Finned X-Wing](https://www.sudokuwiki.org/Finned_X_Wing)
27. [ ] [Finned Swordfish](https://www.sudokuwiki.org/Finned_Swordfish)
28. [ ] [Alternating Inference Chains](https://www.sudokuwiki.org/Alternating_Inference_Chains)
29. [ ] [Sue-de-Coq](https://www.sudokuwiki.org/Sue_De_Coq)
30. [ ] [Digit Forcing Chains](https://www.sudokuwiki.org/Digit_Forcing_Chains)
31. [ ] [Nishio Forcing Chains](https://www.sudokuwiki.org/Nishio_Forcing_Chains)
32. [ ] [Cell Forcing Chains](https://www.sudokuwiki.org/Cell_Forcing_Chains)
33. [ ] [Unit Forcing Chains](https://www.sudokuwiki.org/Unit_Forcing_Chains)
34. [ ] [Almost Locked Sets](https://www.sudokuwiki.org/Almost_Locked_Sets)
35. [ ] [Death Blossom](https://www.sudokuwiki.org/Death_Blossom)
36. [ ] [Pattern Overlay Method](https://www.sudokuwiki.org/Pattern_Overlay)
37. [ ] [Quad Forcing Chains](https://www.sudokuwiki.org/Quad_Forcing_Chains)
38. [ ] "Trial and Error"
