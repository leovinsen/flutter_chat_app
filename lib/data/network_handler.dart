import 'package:firebase_database/firebase_database.dart';

class NetworkHandler {

  static final NetworkHandler instance = NetworkHandler._internal();
  static final FirebaseDatabase db = FirebaseDatabase.instance;

  NetworkHandler._internal();

  Future<String> fetchPublicId(String token) async {
    var snapshot = await db.reference().child('users/$token').once();
    return snapshot.value;
  }

}