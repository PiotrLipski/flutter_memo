import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tuple/tuple.dart';

enum Event {
  init,
  ready,
  restart,
  generate,
  list,
  open,
  close,
  hide,
  start_game,
  stop_game
}

class Message extends Tuple2<Event, dynamic> {
  Message.init(List<WordPair> list) : super(Event.init, list);
  Message.ready() : super(Event.ready, null);
  Message.restart() : super(Event.restart, null);
  Message.generate(int numberOfItems) : super(Event.generate, numberOfItems);
  Message.list(List<WordPair> list) : super(Event.list, list);
  Message.open(Tuple2<Key, WordPair> tuple) : super(Event.open, tuple);
  Message.close(Tuple2<Key, WordPair> tuple) : super(Event.close, tuple);
  Message.hide(Tuple2<Key, WordPair> tuple) : super(Event.hide, tuple);
  Message.startGame() : super(Event.start_game, null);
  Message.stopGame() : super(Event.stop_game, null);
}

class Controller {
  final StreamController<Message> _sc = StreamController.broadcast();

  Stream<Message> get stream => _sc.stream;

  List<WordPair> wordPairs;

  void send(Message e) {
    _sc.sink.add(e);
  }

  List<Tuple2<Key, WordPair>> _previousCards = [];

  close() {
    _sc.close();
  }

  int numberOfCards = 0;
  int numberOfMatched = 0;

  bool started = false;

  Controller() {
    stream.listen((message) {
      switch (message.item1) {
        case Event.init:
          wordPairs = message.item2;
          send(Message.ready());
          break;
        case Event.generate:
          numberOfCards = message.item2;
          wordPairs.shuffle();
          send(Message.list(wordPairs.take(numberOfCards).toList()));
          break;
        case Event.restart:
          wordPairs.shuffle();
          started = false;
          numberOfMatched = 0;
          break;
        case Event.open:
          if (!started) {
            started = true;
            send(Message.startGame());
          }
          if (_previousCards.length == 0) {
            _previousCards.add(message.item2);
          } else if (_previousCards.length == 1) {
            if (_previousCards.last.item2.first == message.item2.item2.second) {
              send(Message.hide(_previousCards.last));
              _previousCards.removeLast();
              send(Message.hide(message.item2));
              numberOfMatched += 1;
              if (numberOfMatched == numberOfCards) {
                numberOfMatched = 0;
                send(Message.stopGame());
              }
            } else {
              _previousCards.add(message.item2);
            }
          } else if (_previousCards.length == 2) {
            _previousCards.forEach((card) {
              send(Message.close(card));
            });
            _previousCards.add(message.item2);
          } else {
            throw Exception(
                "not expected this, _previousCards = $_previousCards");
          }
          break;
        case Event.close:
          _previousCards
              .removeWhere((element) => element.item1 == message.item2.item1);
          break;
        default:
      }
    });
  }
}

class WordPair extends Tuple2<String, String> {
  WordPair(first, second) : super(first, second);
  String get first => super.item1;
  String get second => super.item2;
  WordPair flip() => WordPair(second, first);
}
