/// Possible values for a Sudoku cell
class Possible {
  late final _possible;

  Possible([initial = true]) {
    _possible = List<bool>.filled(9, initial);
  }

  Possible.value(int value) {
    _possible = List.generate(9, (index) => index == value - 1 ? true : false);
  }

  int get count => _possible.where((element) => element == true).length;
  //_possible.fold(0, (previous, element) => element ? previous + 1 : previous);

  bool isPossible(int value) {
    return _possible[value - 1];
  }

  bool operator [](int value) => _possible[value - 1];
  void operator []=(int value, bool possible) =>
      _possible[value - 1] = possible;

  String toString() {
    return List.generate(
      9,
      (i) => _possible[i] ? (i + 1).toString() : '',
    ).join('');
  }

  bool clear(int value) {
    if (_possible[value - 1]) {
      _possible[value - 1] = false;
      return true;
    }
    return false;
  }

  void toggle(int value) {
    _possible[value - 1] = !_possible[value - 1];
  }

  int unique() {
    if (count == 1) {
      return _possible.indexOf(true) + 1;
    }
    return 0;
  }

  bool remove(Possible possible) {
    var updated = false;
    for (var value = 1; value < 10; value++) {
      if (possible.isPossible(value)) {
        if (this.clear(value)) {
          updated = true;
        }
      }
    }
    return updated;
  }

  Possible.from(Possible other) {
    _possible = List.from(other._possible);
  }

  Possible subtract(Possible other) {
    var possible = Possible.from(this);
    for (var value = 1; value < 10; value++) {
      if (other[value]) {
        possible[value] = false;
      }
    }
    return possible;
  }
}

Possible unionPossible(List<Possible> possibles) {
  var result = Possible(false);
  for (var value = 1; value < 10; value++) {
    result[value] = possibles.fold(false,
        (previousValue, possible) => possible[value] ? true : previousValue);
  }
  return result;
}
