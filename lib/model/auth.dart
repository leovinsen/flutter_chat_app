import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_app/model/cache_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class BaseAuth {

  Future<String> currentUser();
  Future<ResultMessage> signIn(String email, String password);
  Future<String> createUser(String email, String password);
  Future<void> signOut();
  Future<void> storeUserId(String userId);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<ResultMessage> signIn(String email, String password) async {
    var result;
    //String result;
    try{
      FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      CacheHandler.storeUserAuthId(user.uid);
      result = ResultMessage(message: user.uid, code: ResultCode.success);
    } catch (e){
      result = ResultMessage(message: e.toString(), code:ResultCode.wrongEmail);
      print(e.toString());
    }

    return result;
  }

  Future<String> createUser(String email, String password) async {
    String result;

    try{
      FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      result = user.uid;
      CacheHandler.storeUserAuthId(user.uid);
    } catch (e){
      result = e;
    }
    return result;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> storeUserId(String userId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('userId', userId);
  }
  
  

}

enum ResultCode{
  success,
  wrongEmail,
  wrongPassword,
}

class ResultMessage {
  String message;
  ResultCode code;
  
  ResultMessage({this.message, this.code});
  
}