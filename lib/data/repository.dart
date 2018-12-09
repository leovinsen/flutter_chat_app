import 'package:flutter_chat_app/data/cache_database.dart';



class Repository {

  static final Repository _repo = Repository._internal();



  CacheDatabase database;

  static Repository get() {
    return _repo;
  }

  Repository._internal() {
    database = CacheDatabase.get();
  }
//
//  ///Called when app is first started,
//  ///determine whether user is signed in or not
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

//  _uniqueAuthId = await getUserAuthToken();
//  if(_uniqueAuthId != null) {
//  _publicId = await getUserPublicId();
//  _authStatus = _publicId == null ? AuthStatus.incompleteRegistration : AuthStatus.signedIn;
//  } else {
//  _authStatus =AuthStatus.notSignedIn;
//  }

//  Future<String> getUserAuthToken() async {
//    //Get user Auth ID from local storage
//    String uniqueAuthId = CacheHandler.getUserFirebaseAuthId();
//
//    //If not found, try online
//    if (uniqueAuthId == null) uniqueAuthId = await auth.currentUser();
//
//    return uniqueAuthId;
//  }

//  ///TODO: Change to Future<String>
//  Future<String> getUserPublicId() async {
//    //String _publicId = CacheHandler.getUserPublicId();
//
//    if (_publicId == null){
//      var db = FirebaseDatabase.instance;
//      var usersBranch = db.reference().child('users');
//      DataSnapshot snapshot = await usersBranch.child(_uniqueAuthId).once();
//      _publicId = snapshot.value;
//    }
//    return _publicId ?? "";
//  }




}