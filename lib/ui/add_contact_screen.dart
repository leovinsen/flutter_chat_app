import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';

class AddContactScreen extends StatefulWidget {
  @override
  AddContactScreenState createState() {
    return new AddContactScreenState();
  }
}

class AddContactScreenState extends State<AddContactScreen> {
  final TextEditingController _idFieldController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a User'),
      ),
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
    AppData data= AppData.of(context);
    setState(() {
      loading = true;
    });
    String contactId = _idFieldController.text;
//    FirebaseDatabase db = FirebaseDatabase.instance;
//    DataSnapshot snapshot = await db.reference()
//        .child('usersInfo/$contactId')
//        .once();

    SnackBar snackBar;
    if(await data.doesContactExist(contactId)){
      await data.addContact(contactId);
      snackBar = SnackBar(
          content: Row(
            children: <Widget>[
              Icon(Icons.check, color: Colors.green,),
              SizedBox(width: 10.0,),
              Text('User $contactId successfully added.')
            ],
          ),
          duration: Duration(seconds: 2)
      );
    } else {

      snackBar = SnackBar(
        content: Row(
          children: <Widget>[
            Icon(Icons.warning, color: Colors.yellow,),
            SizedBox(width: 10.0,),
            Text('User $contactId not found.')
          ],
        ),
        duration: Duration(seconds: 2));
    }

    setState(() {
      loading = false;
    });
    Scaffold.of(context).showSnackBar(snackBar);
  }
}

