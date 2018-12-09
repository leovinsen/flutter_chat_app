import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AddContactScreen extends StatefulWidget {
  final String userPublicId;

  const AddContactScreen(this.userPublicId);

  @override
  AddContactScreenState createState() {
    return new AddContactScreenState();
  }
}

class AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _idFieldController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Builder(
        builder: (context){
          return _body(context);
        },
      )
    );
  }

  Widget _body(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _idFieldController,
              keyboardType: TextInputType.text,
              autofocus: true,
              textCapitalization: TextCapitalization.none,
            ),
          ),

          loading ? CircularProgressIndicator() : IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _addContact(context)
          )

        ],
      ),
    );
  }

  Future _addContact(BuildContext context) async {
    setState(() {
      loading = true;
    });
    String contactId = _idFieldController.text;
    FirebaseDatabase db = FirebaseDatabase.instance;
    DataSnapshot snapshot = await db.reference()
        .child('usersInfo/$contactId')
        .once();

    ///If user exists, value will be non-null
    if (snapshot.value != null) {
      await db.reference().child(
          'usersContact/${widget.userPublicId}/$contactId').set(true);
//      await db.reference().child(
//          'usersContact/${widget.userPublicId}/$contactId').push().set(
//          contactId);
      setState(() {
        loading = false;
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('User $contactId successfully added.'),
        duration: Duration(seconds: 2),));
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('User $contactId not found.'),
        duration: Duration(seconds: 2),));
    }
  }
}

