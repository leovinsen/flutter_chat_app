// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_chat_app/main.dart';

void main() {
  test('Testing', () async{
    Auth auth = Auth();
    String email = 'leonardo@admin.com';
    String password = 'leovinsen';
    await auth.signIn(email, password);
    FirebaseDatabase db = FirebaseDatabase.instance;
    DatabaseReference users = db.reference().child('users');
    String uniqueId = await auth.currentUser();
    print(uniqueId);
    auth.currentUser().then((uniqueId){
      print('reached here');
      users.equalTo(uniqueId).once().then((val){
        print(val);
        expect(val, 'leovinsen');
      });
    });
  });
}
