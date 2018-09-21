import 'package:flutter/material.dart';
import 'package:flutter_chat_app/ui/root_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,

      ),
      home: RootPage(),
      routes: {
      },
    );
  }
}
