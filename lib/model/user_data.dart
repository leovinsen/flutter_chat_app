import 'package:firebase_database/firebase_database.dart';

class UserData{
  String _publicId;
  String _displayName;
  String _thumbUrl;

  UserData(String publicId, String displayName, String thumbUrl){
    _publicId = publicId;
    _displayName = displayName;
    _thumbUrl = thumbUrl;
  }

  UserData.fromSnapshot(DataSnapshot snapshot)
      : _publicId = snapshot.value['publicId'],
        _displayName = snapshot.value['displayName'],
        _thumbUrl = snapshot.value['thumbUrl'];

  toJson(){
    return {
      'publicId' : _publicId,
      'displayName' : _displayName,
      'thumbUrl' : _thumbUrl,
    };
  }

  String get publicId => _publicId;

//  set publicId(String value) {
//    _publicId = value;
//  }

  String get displayName => _displayName;

//  set displayName(String value) {
//    _displayName = value;
//  }

  String get thumbUrl => _thumbUrl;
//
//  set thumbUrl(String value) {
//    _thumbUrl = value;
//  }

  @override
  String toString() {
    // TODO: implement toString
    return 'publicId: $_publicId, displayName: $_displayName, thumbUrl: $_thumbUrl}';
  }

}