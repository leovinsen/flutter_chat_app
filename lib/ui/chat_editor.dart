import 'package:flutter/material.dart';

class ChatEditor extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _controller,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: <Widget>[
                Flexible(child: Text('A')),
                Flexible(child: Text('B'))
              ],
            ),
          )
        ],
      )
    );
  }
}
