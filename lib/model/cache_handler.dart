import 'dart:async';

import 'package:flutter_chat_app/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheHandler{

  static final String fieldUserFirebaseAuthId = 'userFirebaseAuthId';
  static final String fieldRegistered = 'registered';
  static final String fieldUserPublicId = 'userPublicId';
  static final String fieldUserDisplayName = 'userDisplayName';

  static SharedPreferences localStorage;

  static final String fieldUserThumbUrl = 'userThumbUrl';


  static Future init() async {
    if(localStorage == null) localStorage = await SharedPreferences.getInstance();
  }

  static void storeUserAuthId(String userAuthId){
    localStorage.setString(fieldUserFirebaseAuthId, userAuthId);
  }

  static void storeUserRegistrationStatus(bool status){
    localStorage.setBool(fieldRegistered, true);
  }

  static void storeUserPublicId(String publicId){
    localStorage.setString(fieldUserPublicId, publicId);
  }

  static void storeUserDisplayName(String displayName){
    localStorage.setString(fieldUserDisplayName, displayName);
  }

  static void storeUserThumbnailUrl(String url){
    localStorage.setString(fieldUserThumbUrl, url);
  }

  static String getUserFirebaseAuthId(){
    return localStorage.getString(fieldUserFirebaseAuthId);
  }

  static bool getUserRegistrationStatus(){
    return localStorage.getBool(fieldRegistered);
  }

  static String getUserPublicId(){
    return localStorage.getString(fieldUserPublicId);
  }

  static String getUserDisplayName(){
    return localStorage.getString(fieldUserDisplayName);
  }

  static String getUserThumbUrl(){
    return localStorage.getString(fieldUserThumbUrl);
  }

  static UserModel getUserModel(){
    return UserModel(getUserPublicId(), getUserDisplayName() , getUserThumbUrl());
  }

  static void clearUserCreds(){
//    localStorage.remove(fieldUserAuthId);
//    localStorage.remove(fieldRegistered);
  localStorage.clear();
  }
}