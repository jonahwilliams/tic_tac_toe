import 'package:tic_tac_toe.ui/ui.dart';
import 'package:tic_tac_toe.state/state.dart';
import 'dart:html';
import 'dart:async';

/// An example of an app that is wired up to itself with turn switching.
void main() {
  final input = new StreamController<Board>();
  final app = new App(input.stream, document.getElementById('app'), Space.x);
  final output = app.output;
  output.listen((b) {
    input.add(b);
    app.switchPlayer();
  });
  input.add(new Board());
  app.initialize();
}
