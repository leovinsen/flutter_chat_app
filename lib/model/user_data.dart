import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chat_app/model/user_model.dart';
import 'package:scoped_model/scoped_model.dart';


class UserData extends Model{

  final String uniqueAuthId;
  final UserModel userModel;


  UserData({this.uniqueId, this.currentUser, this.contacts});



}