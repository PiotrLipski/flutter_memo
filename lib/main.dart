import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

import 'controller.dart';
import 'mycard.dart';

void main() => runApp(MyApp());

Controller controller = new Controller();

Future<List<WordPair>> _generateWordPairs() {
  return rootBundle
      .loadString('assets/dictionary.csv')
      .asStream()
      .transform(LineSplitter())
      .map((line) => line.split(","))
      .map((array) => WordPair(array[0], array[1]))
      .toList();
}

class MyApp extends StatelessWidget {
  Stopwatch stopwatch = new Stopwatch();
  //TODO: stop emiting ticks when timer stopped?

  @override
  Widget build(BuildContext context) {
    //TODO this is not a right place to init controller
    _generateWordPairs()
        .then((wordPairs) => controller.send(Message.init(wordPairs)));

    controller.stream
        .where((event) => event.item1 == Event.new_game)
        .listen((event) {
      stopwatch.stop();
      stopwatch.reset();
    });

    controller.stream
        .where((event) => event.item1 == Event.start_game)
        .listen((event) {
      stopwatch.start();
    });

    controller.stream
        .where((event) => event.item1 == Event.stop_game)
        .listen((event) {
      stopwatch.stop();
    });

    controller.stream
        .where((event) => event.item1 == Event.replay)
        .listen((event) {
      stopwatch.stop();
      stopwatch.reset();
    });

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("Memo"),
      ),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
            Container(height: 200, child: Center(child: Timer(stopwatch))),
            Expanded(child: RandomWords()),
            ButtonBar(
              children: [
                RaisedButton(
                  onPressed: () => controller.send(Message.replay()),
                  child: const Text('Replay', style: TextStyle(fontSize: 20)),
                ),
                RaisedButton(
                  onPressed: () => controller.send(Message.new_game()),
                  child: const Text('New game', style: TextStyle(fontSize: 20)),
                )
              ],
            )
          ])),
    ));
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  @override
  void initState() => super.initState();

  List<MyCard> _cards;

  @override
  Widget build(BuildContext context) {
    int _columns = 4;
    int _rows = 4;
    return StreamBuilder<Message>(
        stream: controller.stream.where((message) =>
            Set.of([Event.new_game, Event.ready, Event.list, Event.replay])
                .contains(message.item1)),
        builder: (context, AsyncSnapshot<Message> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("...");
          } else {
            if (snapshot.data.item1 == Event.new_game ||
                snapshot.data.item1 == Event.ready) {
              controller.send(Message.generate((_columns * _rows) ~/ 2));
              return Container();
            } else if (snapshot.data.item1 == Event.replay) {
              return GridView.count(
                  crossAxisCount: _columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: const EdgeInsets.all(5),
                  children: _cards);
            } else if (snapshot.data.item1 == Event.list) {
              print(snapshot.data.item2);
              List<WordPair> wordPairs = snapshot.data.item2;
              wordPairs.addAll(wordPairs.map((wp) => wp.flip()).toList());
              _cards = wordPairs
                  .map((wp) => MyCard(wordPair: wp, controller: controller))
                  .toList();
              _cards.shuffle();
              return GridView.count(
                  crossAxisCount: _columns,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  padding: const EdgeInsets.all(5),
                  children: _cards);
            } else {
              return Text("UNKNOWN MESSAGE ${snapshot.data.toString()}",
                  style: TextStyle(fontSize: 16));
            }
          }
        });
  }
}

class Timer extends StatelessWidget {
  final Stopwatch stopwatch;
  Timer(this.stopwatch);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.periodic(Duration(milliseconds: 20)),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Duration duration =
              Duration(milliseconds: stopwatch.elapsedMilliseconds);
          int mins = duration.inMinutes;
          int secs = duration.inSeconds - duration.inMinutes * 60;
          int millis = duration.inMilliseconds - duration.inSeconds * 1000;
          return Text(
            "${NumberFormat("00").format(mins)}:${NumberFormat("00").format(secs)}:${NumberFormat("000").format(millis)}",
            style: new TextStyle(
              fontSize: 48.0,
            ),
          );
        });
  }
}
