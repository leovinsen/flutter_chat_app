import 'package:flutter/material.dart';
import 'package:flutter_chat_app/app_model.dart';
import 'package:flutter_chat_app/auth.dart';
import 'package:flutter_chat_app/register_page.dart';
import 'package:flutter_chat_app/root_page.dart';
import 'package:scoped_model/scoped_model.dart';
import 'login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: RootPage(),
//      home: ScopedModel<AppModel>(
//        model: AppModel(),
//        child: RootPage(title: title),
//      ),
      routes: {
        LoginPage.tag: (context) => LoginPage(),
        RegisterPage.tag: (context) => RegisterPage()
      },
    );
  }
}
