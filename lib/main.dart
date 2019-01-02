import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/ui/root_page.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return ScopedModel<AppData>(
        model: AppData(),
        child: MaterialApp(
          title: 'Flutter Chat App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.lightBlue,

          ),
          home: RootPage(),
          routes: {
          },
        )
    );
  }
}
