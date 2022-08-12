/// Possible values for a Sudoku cell
class Possible {
  late final List<bool> _possible;
  late final int _base;

  Possible([initial = true, this._base = 1]) {
    _possible = List<bool>.filled(9, initial);
  }

  Possible.value(int value, [this._base = 1]) {
    _possible =
        List.generate(9, (index) => index == value - _base ? true : false);
  }

  Possible.from(Possible other) {
    _possible = List.from(other._possible);
    _base = other._base;
  }

  int get count => _possible.where((element) => element == true).length;
  //_possible.fold(0, (previous, element) => element ? previous + 1 : previous);

  bool isPossible(int value) {
    return _possible[value - _base];
  }

  bool operator [](int value) => _possible[value - _base];
  void operator []=(int value, bool possible) =>
      _possible[value - _base] = possible;

  String toString() {
    return List.generate(
      9,
      (i) => _possible[i] ? (i + _base).toString() : '',
    ).join('');
  }

  bool clear(int value) {
    if (_possible[value - _base]) {
      _possible[value - _base] = false;
      return true;
    }
    return false;
  }

  void toggle(int value) {
    _possible[value - _base] = !_possible[value - _base];
  }

  int unique() {
    if (count == 1) {
      return _possible.indexOf(true) + _base;
    }
    return 0;
  }

  bool remove(Possible other) {
    var updated = false;
    assert(_base == other._base);
    for (var value = _base; value < _base + 9; value++) {
      if (other.isPossible(value)) {
        if (this.clear(value)) {
          updated = true;
        }
      }
    }
    return updated;
  }

  bool removeOther(Possible keep) {
    var updated = false;
    assert(_base == keep._base);
    for (var value = _base; value < _base + 9; value++) {
      if (!keep.isPossible(value)) {
        if (this.clear(value)) {
          updated = true;
        }
      }
    }
    return updated;
  }

  Possible subtract(Possible other) {
    assert(_base == other._base);
    var result = Possible.from(this);
    for (var value = 0; value < 9; value++) {
      if (other._possible[value]) {
        result._possible[value] = false;
      }
    }
    return result;
  }

  getOther(int value) {
    for (var other = _base; other < _base + 9; other++) {
      if (value != other && _possible[other - _base]) {
        return other;
      }
    }
    return 0;
  }

  bool equals(Possible other) {
    for (var value = 0; value < 9; value++) {
      if (_possible[value] != other._possible[value]) return false;
    }
    return true;
  }

  bool reduce(Possible possible) {
    var updated = false;
    for (var value = _base; value < _base + 9; value++) {
      if (!possible[value]) {
        if (clear(value)) updated = true;
      }
    }
    return updated;
  }
}

Possible unionPossible(List<Possible> possibles, [base = 1]) {
  var result = Possible(false, base);
  for (var value = 0; value < 9; value++) {
    result._possible[value] = possibles.fold(
        false,
        (previousValue, possible) =>
            possible._possible[value] ? true : previousValue);
  }
  return result;
}

List<int> countPossible(List<Possible> possibles) {
  var result = List<int>.filled(9, 0);
  for (var value = 0; value < 9; value++) {
    result[value] = possibles.fold(
        0,
        (previousValue, possible) =>
            possible._possible[value] ? previousValue + 1 : previousValue);
  }
  return result;
}
