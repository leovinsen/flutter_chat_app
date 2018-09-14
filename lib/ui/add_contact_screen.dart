import 'package:flutter/material.dart';
class AddContactScreen extends StatelessWidget {
  final TextEditingController _idFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
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

            IconButton(
              icon: Icon(Icons.add),
              onPressed: (){
                Navigator.pop(context, _idFieldController.text);
              },
            )

          ],
        ),
      ),
    );
  }
}

