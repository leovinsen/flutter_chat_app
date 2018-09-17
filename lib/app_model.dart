import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/auth.dart';
import 'package:flutter_chat_app/model/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus {
  signedIn,
  register,
  notSignedIn,
}

enum SignInStatus{
  success,
  invalidEmail,
  invalidPassword
}

class AppModel extends Model{
  AuthStatus _authStatus;
  final Auth _auth = Auth();
  final FirebaseDatabase db = FirebaseDatabase.instance;
  UserModel userModel;
  DatabaseReference usersRef;
  //DatabaseReference contactsRef;
  DatabaseReference usersInfoRef;
  //SharedPreferences _prefs;
  String _uid;
  bool _ready = false;

  Auth get auth => _auth;
  String get uid => _uid;

  AuthStatus get authStatus => _authStatus;
  bool get ready => _ready;

  AppModel() {
    usersRef = db.reference().child('users');
    usersInfoRef = db.reference().child('usersInfo');
    //contactsRef = db.reference().child('contacts');

    init();
    //getPrefs();
  }

  void init(){
    //Retrieve user model
    auth.currentUser().then((uniqueId){
      _uid = uniqueId;
      //If user is signed in
      if(uniqueId != null){
        _authStatus = AuthStatus.signedIn;

//        usersRef.child(userId).once().then((snapshot){
//        print(snapshot.value);
////          userModel = UserModel.fromSnapshot(snapshot);
//        });
      } else {
        _authStatus = AuthStatus.notSignedIn;
      }
      _ready = true;
      notifyListeners();
    });
  }
  void moveToRegister(){
    _authStatus = AuthStatus.register;
    notifyListeners();
  }

  void moveToLogin(){
    _authStatus = AuthStatus.notSignedIn;
    notifyListeners();
  }

  Future<SignInStatus> signInWithEmail(String email, String password)async{
    try{
      _uid = await _auth.signIn(email, password);

      _authStatus = AuthStatus.signedIn;
      notifyListeners();
      return SignInStatus.success;

    } catch (e){

      print(e);
      String err = e.toString();
      if(err.contains('There is no user record') || err.contains('The email address is badly formatted')){
        return SignInStatus.invalidEmail;
      } else if (err.contains('The password is invalid')){
        return SignInStatus.invalidPassword;
      } else {
        print(e);
        return null;
      }
    }
  }

  void signOut(){
    _auth.signOut();
    _authStatus = AuthStatus.notSignedIn;
    notifyListeners();
  }

  Future<SignInStatus> register(String email, String password, String displayName, String publicId)async{
    try {
      _auth.createUser(email, password).then((uniqueId){
        //Associate the unique ID generated by Firebase with Username chosen by the user.
        //Relationship is defined as uniqueID : publicID under /users/
        usersRef.child(uniqueId).set(publicId);

        //Create a record in /usersInfo/
        //Relationship is defined as publicID : UserModel.toJson()


        //userModel = UserModel();
        //userModel.displayName = displayName;
        //userModel.publicId = publicId;


        usersInfoRef.child(publicId).set(userModel.toJson());

        _uid = uniqueId;


        _authStatus = AuthStatus.signedIn;
        notifyListeners();
        return SignInStatus.success;
      });
    } catch (e){
      print(e);
      String err = e.toString();
      if(err.contains('There is no user record') || err.contains('The email address is badly formatted')){
        return SignInStatus.invalidEmail;
      } else if (err.contains('The password is invalid')){
        return SignInStatus.invalidPassword;
      } else {
        print(e);
        return null;
      }
    }
  }




//  void getPrefs() async{
//    _prefs =  await SharedPreferences.getInstance();
//    //_uid = _prefs.getString('uid');
//  }

  static AppModel of(BuildContext context) =>
      ScopedModel.of<AppModel>(context);

}