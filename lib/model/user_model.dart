import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String _publicId;
  String _displayName;
  String _thumbUrl;
  //Map _contacts;

//  List get contactsKey{
//    if(_contacts == null) _contacts = {};
//    return _contacts.keys.toList();
//  }
//
//  int get numOfContacts => _contacts.length;
//
//  Map get contacts => _contacts;


  UserModel(String publicId, String displayName, String thumbUrl){
    _publicId = publicId;
    _displayName = displayName;
    _thumbUrl = thumbUrl;
//    _contacts = {};
  }




  UserModel.fromSnapshot(DataSnapshot snapshot)
      : _publicId = snapshot.value['publicId'],
        _displayName = snapshot.value['displayName'],
        _thumbUrl = snapshot.value['thumbUrl'];
//        _contacts = snapshot.value['contacts']
//  {
//    if (_contacts == null) _contacts = {};
//  }

  toJson(){
    return {
      'publicId' : _publicId,
      'displayName' : _displayName,
      'thumbUrl' : _thumbUrl,
//      'contacts' : _contacts,
    };
  }

  String get publicId => _publicId;

//  bool addContact(String publicId){
//    if(_contacts.containsKey(publicId)){
//      return false;
//    } else {
//      _contacts[publicId] = true;
//      return true;
//    }
//  }

  //Returns value of the key (true) if successful
  //Null if failed
//  bool removeContact(String publicId){
//    return _contacts.remove(publicId);
//  }

  set publicId(String value) {
    _publicId = value;
  }

  String get displayName => _displayName;

  set displayName(String value) {
    _displayName = value;
  }

  String get thumbUrl => _thumbUrl;

  set thumbUrl(String value) {
    _thumbUrl = value;
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'publicId: $_publicId, displayName: $_displayName, thumbUrl: $_thumbUrl}';
  }

}