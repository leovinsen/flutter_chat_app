import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Auth {
  static final Auth instance = Auth._internal();
  FirebaseAuth _firebaseAuth;

  Auth._internal(){
    _firebaseAuth = FirebaseAuth.instance;
  }

  Future<ResultMessage> signIn(String email, String password) async {
    var result;
    //String result;
    try{
      FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
//      CacheHandler.storeUserAuthId(user.uid);
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
//      CacheHandler.storeUserAuthId(user.uid);
    } catch (e){
      result = e;
    }
    return result;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    print('userUID: ${user.uid}');
    return user != null ? user.uid : null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> storeUserId(String userId) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('userId', userId);
  }

//  Future<AuthStatus> authenticate() async {
//    String uniqueAuthId = await Auth.instance.currentUser();
//    if(uniqueAuthId != null){
//      var snapshot = await FirebaseDatabase.instance.reference().child('users/$uniqueAuthId').once();
//      String publicId = snapshot.value;
//      return publicId == null ? AuthStatus.incompleteRegistration : AuthStatus.signedIn;
//    } else {
//      return AuthStatus.notSignedIn;
//    }
//  }
  

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