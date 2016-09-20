import 'package:tic_tac_toe.state/state.dart';
import 'dart:async';
import 'dart:html';

/// all of the initial DOM needed to draw a tic tac toe board.
final Element emptyBoard = new Element.div()
  ..className = 'board'
  ..children = new List.generate(
      9,
      (i) => new Element.div()
        ..classes = ['cell', 'empty']
        ..text = ''
        ..id = '$i');

/// Element to hold current turn tracker
final Element currentTurn = new Element.div()
  ..id = 'turn-tracker'
  ..text = '';

/// App.
class App {
  final StreamController<Board> _output = new StreamController();
  final Stream<Board> _input;
  final Element _host;
  Space _player;
  List<Element> _cells;
  Element _turn;
  Board _board;
  bool _locked = false;

  /// Constructs an App.
  App(this._input, this._host, Space player) {
    assert(player != Space.empty);
    _player = player;
  }

  /// Returns a [Stream] of [Board] from input changes.
  Stream<Board> get output => _output.stream;

  /// Binds events to host components and begins stream subscriptions.
  void initialize() {
    _render();
    _host.onClick.matches('.cell').listen(_handle);
    _input.listen((board) {
      if (board.isOver()) {
        print('winner is ${board.getWinner()}');
      }
      _board = board;
      _update();
    });
  }

  String _spaceToString(Space space) =>
      space == Space.x ? 'X' : (space == Space.o ? 'O' : '');

  /// updates the class and text values for each cell.
  void _update() {
    final spaces = _board.toValues();
    for (int i = 0; i < 9; i++) {
      final cell = _cells[i];
      final space = spaces[i];
      cell..text = _spaceToString(space);
    }
    _turn.text = 'Current Turn: ${_spaceToString(_board.getTurn())}';
    _locked = false;
  }

  /// binds an empty board to the host component after clearing DOM.
  void _render() {
    _host.children.clear();
    _host.children.add(currentTurn);
    _host.children.add(emptyBoard);

    _cells = document.getElementsByClassName('cell');
    _turn = document.getElementById('turn-tracker');
  }

  /// handles onClick event dispatch.
  ///
  /// Prevents moving on other players turns and on invalid spaces.
  void _handle(MouseEvent e) {
    final target = e.target;
    final values = _board.toValues();
    if (target is Element && !_locked && _board.getTurn() == _player) {
      final key = int.parse(target.id);
      if (values[key] == Space.empty) {
        _output.add(_board.move(key % 3, key ~/ 3));
        _locked = true;
      }
    }
  }

  /// Switches the active player.
  void switchPlayer() {
    if (_player == Space.x) {
      _player = Space.o;
    } else {
      _player = Space.x;
    }
  }
}
