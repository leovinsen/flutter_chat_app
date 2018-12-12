import 'package:firebase_database/firebase_database.dart';

class UserData{
  static final kPublicId = "publicId";
  static final kDisplayName = "displayName";
  static final kThumbUrl = "thumbUrl";

  String _publicId,
      _displayName,
      _thumbUrl;

  UserData(String publicId, String displayName, String thumbUrl){
    _publicId = publicId;
    _displayName = displayName;
    _thumbUrl = thumbUrl;
  }

  UserData.fromSnapshot(DataSnapshot snapshot)
      : _publicId = snapshot.value[kPublicId],
        _displayName = snapshot.value[kDisplayName],
        _thumbUrl = snapshot.value[kThumbUrl];

  UserData.fromMap(Map map) {
    _publicId = map[kPublicId] as String;
    _displayName = map[kDisplayName] as String;
    _thumbUrl = map[kThumbUrl] as String;
  }

  toJson(){
    return {
      kPublicId : _publicId,
      kDisplayName : _displayName,
      kThumbUrl : _thumbUrl,
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