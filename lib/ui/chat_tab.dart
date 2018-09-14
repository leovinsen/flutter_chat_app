import 'package:flutter/material.dart';

class ChatTab extends StatelessWidget {
  final VoidCallback onSignOut;

  ChatTab(this.onSignOut);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlatButton(
        color: Colors.indigoAccent,
        child: Text('Sign Out'),
        onPressed: onSignOut,
      ),
    );
  }
}
