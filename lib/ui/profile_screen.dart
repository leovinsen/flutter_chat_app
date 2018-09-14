import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/user_model.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  ProfileScreen({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(30.0),
            child: CircleAvatar(
              radius: 100.0,
              child: Image.asset('assets/profile_default_thumbnail_64px.png', fit: BoxFit.cover,),
            ),
          ),

          Card(
            child: ListTile(
              title: Text(user.publicId),
              subtitle: Text('Others can find you by using your publicID',style: TextStyle(fontSize: 10.0)),
            ),
          ),

          Card(
            child: ListTile(
              title: Text(user.displayName),
              trailing: IconButton(icon: Icon(Icons.edit), onPressed: null),
            ),
          )

        ],
      )
    );
  }
}
