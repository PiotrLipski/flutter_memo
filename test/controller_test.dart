// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/controller.dart';
import 'package:tuple/tuple.dart';

void main() {
  group('Controller', () {
    WordPair cat = WordPair("cat", "kot");
    WordPair kot = cat.flip();
    WordPair dog = WordPair("dog", "pies");
    WordPair bird = WordPair("bird", "ptak");
    WordPair fish = WordPair("fish", "ryba");

    Tuple2<Key, WordPair> t1 = Tuple2.fromList([UniqueKey(), cat]);
    Tuple2<Key, WordPair> t2 = Tuple2.fromList([UniqueKey(), kot]);
    Tuple2<Key, WordPair> t3 = Tuple2.fromList([UniqueKey(), dog]);
    Tuple2<Key, WordPair> t4 = Tuple2.fromList([UniqueKey(), bird]);

    test('generate ready after init complete', () {
      Controller ctrl = new Controller();
      ctrl.send(Message.init([cat, dog, bird, fish]));
      expectLater(ctrl.stream, emits(Message.ready()));
    });

    test('hide matching cards', () {
      Controller ctrl = new Controller();
      ctrl.send(Message.open(t1));
      ctrl.send(Message.open(t2));
      expectLater(
          ctrl.stream,
          emitsInOrder([
            Tuple2.fromList([Event.hide, t1]),
            Tuple2.fromList([Event.hide, t2])
          ]));
    });

    test('close previously opened two cards', () {
      Controller ctrl = new Controller();
      ctrl.send(Message.open(t1));
      ctrl.send(Message.open(t3));
      ctrl.send(Message.open(t4));
      expectLater(
          ctrl.stream,
          emitsInOrder([
            Tuple2.fromList([Event.close, t1]),
            Tuple2.fromList([Event.close, t3])
          ]));
    });
  });
}
