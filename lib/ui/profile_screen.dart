import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/user_data.dart';

class ProfileScreen extends StatelessWidget {
  final UserData user;
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

          publicIdContainer(context),
          displayNameContainer(context),

        ],
      )
    );
  }

  Container publicIdContainer(BuildContext context){
    return Container(
        alignment: Alignment.center,
        child: ListTile(
          title: Text('Public ID'),
          subtitle: Text(user.publicId, style: blueSubtitle(context)),
        ),
        decoration: whiteBoxDecoration()
    );
  }

  Container displayNameContainer(BuildContext context){
    return Container(
      alignment: Alignment.center,
        child: ListTile(
          title: Text('Display Name'),
          subtitle: Text(user.displayName, style: blueSubtitle(context),),
          trailing: IconButton(icon: Icon(Icons.edit), onPressed: null),
        ),
      decoration: whiteBoxDecoration(),
    );
  }

  Decoration whiteBoxDecoration(){
    return BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade400, blurRadius: 0.1)
        ]
    );
  }

  TextStyle blueSubtitle(BuildContext context){
    return TextStyle(
      fontSize: 12.0,
      color: Theme.of(context).primaryColorDark
    );
  }

}
