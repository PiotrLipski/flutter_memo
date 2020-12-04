import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import 'controller.dart';

class MyCard extends StatefulWidget {
  final WordPair wordPair;
  final Controller controller;

  MyCard({this.wordPair, this.controller});

  @override
  State<StatefulWidget> createState() => MyCardState(controller);
}

class MyCardState extends State<MyCard> {
  bool closed = true;
  bool hidden = false;

  Key key = UniqueKey();

  final Controller controller;

  MyCardState(this.controller) {
    controller.stream
        .where((event) =>
            event.item2 is Tuple2<Key, WordPair> && event.item2.item1 == key)
        .listen((event) {
      setState(() {
        switch (event.item1) {
          case Event.hide:
            hidden = true;
            break;
          case Event.close:
            closed = true;
            break;
          case Event.open:
            closed = false;
            break;
          default:
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
        minWidth: 100,
        height: 100,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          color: hidden
              ? Colors.white
              : (closed ? Colors.orange : Colors.lightBlue),
          onPressed: () {
            if (hidden) {
              return;
            }
            setState(() {
              if (closed) {
                controller.send(Message.open(Tuple2(key, widget.wordPair)));
              } else {
                controller.send(Message.close(Tuple2(key, widget.wordPair)));
              }
              closed = !closed;
            });
          },
          child: Text(
            closed ? "" : "${widget.wordPair.second}",
            style: TextStyle(fontSize: 14),
          ),
        ));
  }
}
