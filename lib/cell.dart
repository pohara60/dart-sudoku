import 'package:sudoku/possible.dart';

class Cell {
  int _row, _col;
  int? _value;
  var _possible = Possible();
  bool _isFocus = false;
  String _error = '';
  bool _wasUpdated = false;

  Cell(this._row, this._col);
  Cell.value(this._row, this._col, int val) {
    value = val;
  }

  int? get value => _value;
  get isError => _error != '';
  // ignore: unnecessary_getters_setters
  String get error => _error;
  // ignore: unnecessary_getters_setters
  set error(String error) {
    _error = error;
  }

  Possible get possible => _possible;

  int get possibleCount => _possible.count;

  set value(int? value) {
    if (value != null) {
      _value = value;
      _possible = Possible.value(value);
    }
  }

  bool get isSet => _value != null;
  bool get wasUpdated => _wasUpdated;

  bool isPossible(int value) {
    return _possible.isPossible(value);
  }

  void clearUpdate() {
    _error = '';
    _wasUpdated = false;
  }

  String format(bool showPossible) => _value != null
      ? _value.toString()
      : showPossible
          ? _possible.toString()
          : '';

  // ignore: unnecessary_getters_setters
  set isFocus(bool isFocus) {
    _isFocus = isFocus;
  }

  // ignore: unnecessary_getters_setters
  bool get isFocus => _isFocus;

  int get row => _row;
  int get col => _col;

  void togglePossible(int value) {
    _possible.toggle(value);
  }

  bool remove(int value) {
    //this.initPossible();
    if (_possible.isPossible(value)) {
      _possible.toggle(value);
      // var countTrue = 0;
      // var valueTrue;
      // for (var e = 1; e < 10; e++) {
      //   if (this._possible[e - 1]) {
      //     countTrue++;
      //     valueTrue = e;
      //   }
      // }
      // if (countTrue == 1) {
      //   this.value = valueTrue;
      // }
      this._wasUpdated = true;
      return true;
    } else {
      return false;
    }
  }

  @override
  // toString() => _value != null ? _value.toString() : '';
  String toString() {
    var text = '[$_row,$_col] = ${_possible.toString()}';
    return text;
  }

  /// Return location string of [type] 'cell', 'box', 'row' or 'col'
  String location([String type = 'cell']) {
    var location = "";
    if (type == "cell") location = "cell[$_row ,$_col]";
    if (type == "box") location = "square[${_row + (_col - 1) ~/ 3}]";
    if (type == "row") location = "row[$_row]";
    if (type == "column") location = "column[$_col]";
    return location;
  }

  bool checkUnique() {
    if (_value != null) return false;
    var unique = _possible.unique();
    if (unique > 0) {
      value = unique;
      return true;
    }
    return false;
  }

  bool removePossible(Possible possible) {
    return _possible.remove(possible);
  }
}
