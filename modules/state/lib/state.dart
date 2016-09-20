import 'dart:convert';

import 'package:collection/collection.dart';

/// Immutable state object for a Tic-Tac-Toe game.
///
/// ## Creating and using a board
///
/// __Create a new empty game__:
///     var newBoard = new Board();
///
/// __Make a move__:
///     newBoard = oldBoard.move(0, 0);
///
/// __Encode as JSON__:
///     var jsonBoard = oldBoard.toJson();
///
/// __Decode JSON__:
///     var newBoard = new Board.fromJson(jsonBoard);
///
/// ## Determining the winner
///
/// If [isOver] returns `true`, the game is over. At that point you may use
/// [getWinner] to get the space (either [Space.x] or [Space.y]) that won!
class Board {
  static JsonEncoder _toPretty =
      const JsonEncoder.withIndent(' ', _encodeSpace);

  final List<List<Space>> _spaces;

  /// Create a new [Board] object with a blank game board.
  factory Board() => new Board.fromSpaces(const [
        const [
          Space.empty,
          Space.empty,
          Space.empty,
        ],
        const [
          Space.empty,
          Space.empty,
          Space.empty,
        ],
        const [
          Space.empty,
          Space.empty,
          Space.empty,
        ],
      ]);

  /// Create a new [Board] state object from a JSON list.
  factory Board.fromJson(List<List<String>> json) => new Board.fromSpaces(
      json.map/*<Iterable<Space>>*/((r) => r.map/*<Space>*/(_decodeString)));

  /// Create a new [Board] state object from a [List] of [Space]s.
  Board.fromSpaces(Iterable<Iterable<Space>> spaces)
      : _spaces = new List<List<Space>>.unmodifiable(spaces
            .map/*<List<Space>>*/((s) => new List<Space>.unmodifiable(s)));

  static bool _isEqual(Space a, Space b, Space c) => a == b && a == c;

  Space _checkColumn(int n) =>
      _isEqual(_spaces[0][n], _spaces[1][n], _spaces[2][n])
          ? _spaces[0][n]
          : null;

  Space _checkRow(int n) =>
      _isEqual(_spaces[n][0], _spaces[n][1], _spaces[n][2])
          ? _spaces[n][0]
          : null;

  Space _checkDiagonals() =>
      _isEqual(_spaces[0][0], _spaces[1][1], _spaces[2][2])
          ? _spaces[0][0]
          : _isEqual(_spaces[0][2], _spaces[1][1], _spaces[2][0])
              ? _spaces[0][2]
              : null;

  static Space _decodeString(String string) {
    switch (string) {
      case 'o':
        return Space.o;
      case 'x':
        return Space.x;
      default:
        return Space.empty;
    }
  }

  /// Returns a flat list over the values of the board.
  List<Space> toValues() => _spaces.expand((x) => x);

  /// Return what [Space] should go next.
  ///
  /// Throws [StateError] if [isOver] is `true`.
  Space getTurn() {
    if (isOver()) {
      throw new StateError('Game is over');
    }
    final xCount = _spaces
        .map/*<int>*/((r) => r.where((s) => s == Space.x).length)
        .reduce((prev, next) => prev + next);
    final oCount = _spaces
        .map/*<int>*/((r) => r.where((s) => s == Space.o).length)
        .reduce((prev, next) => prev + next);
    return oCount == xCount ? Space.x : Space.o;
  }

  /// Returns what [Space] has won, or `null` if the game is a tie.
  ///
  /// Throws [StateError] if [isOver] is `false`.
  Space getWinner() {
    if (!isOver()) {
      throw new StateError('Game is not over');
    }
    Space winner;
    for (var i = 0; winner == null && i < 2; i++) {
      winner = _checkRow(i);
    }
    for (var i = 0; winner == null && i < 2; i++) {
      winner = _checkColumn(i);
    }
    return winner ?? _checkDiagonals();
  }

  static String _encodeSpace(Space space) {
    switch (space) {
      case Space.o:
        return 'o';
      case Space.x:
        return 'x';
      default:
        return '';
    }
  }

  @override
  int get hashCode => _spaces.toString().hashCode;

  /// Returns whether the game is blank (not started).
  bool isBlank() => _spaces.every((r) => r.every((s) => s == Space.empty));

  /// Returns whether the game should be deemed 'over'.
  bool isOver() => _spaces.every((r) => r.every((s) => s != Space.empty));

  @override
  bool operator ==(Object o) {
    if (o is Board) {
      return const DeepCollectionEquality().equals(_spaces, o._spaces);
    }
    return false;
  }

  /// Create a copy of [Board] with ([x], [y]) set as the current player.
  Board move(int x, int y) {
    var copy = _spaces.map((s) => s.toList()).toList();
    copy[y][x] = getTurn();
    return new Board.fromSpaces(copy);
  }

  /// Converts to a JSON-compatible object.
  List<List<String>> toJson() => _spaces
      .map/*<List<String>>*/((r) => r.map/*<String>*/(_encodeSpace).toList())
      .toList();

  @override
  String toString() => 'TicTacToe ' + _toPretty.convert(_spaces);
}

/// A [Board] board space, which can be blank, an [x] or an [o].
enum Space {
  /// An 'X'
  x,

  /// An 'O'
  o,

  /// No entry in a space.
  empty,
}
