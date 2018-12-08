import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/custom_button.dart';

class ChatEditor extends StatelessWidget {
  final String initialName;
  ChatEditor(this.initialName);

  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _controller.text = initialName;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Enter your name'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                textCapitalization: TextCapitalization.words,
                style: TextStyle(fontSize: 17.0, color: Colors.black),
                maxLength: 20,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                  )
                ),
                autofocus: true,
                controller: _controller,
              ),
            ),
          ),

          Divider(height: 2.0, color: Colors.black,),
          _cancelOkButtons(context),

        ],

      )
    );
  }

  Widget _cancelOkButtons(BuildContext context){
    return Row(
      children: <Widget>[
        Expanded(
            child: CustomButton('CANCEL', () => Navigator.of(context).pop())
        ),
        VerticalDivider(width: 22.0,color: Colors.red, indent: 20.0,),
        Expanded(child: CustomButton(
            'OK', () => Navigator.of(context).pop(_controller.text)),)
      ],
    );
  }
}
