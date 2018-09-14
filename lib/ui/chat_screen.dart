import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_app/model/user_model.dart';

class ChatScreen extends StatefulWidget {
  final UserModel userModel;
  ChatScreen({this.userModel});
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, //false to hide back button
        title: ListTile(
          leading: CircleAvatar(
            radius: 16.0,
            child: Image.asset('assets/profile_default_thumbnail_64px.png'),
          ),
          title: new Text(widget.userModel.displayName),
        ),
        elevation: 6.0,
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
              reverse: true,
              padding: new EdgeInsets.all(6.0),
            )),
        new Divider(height: 1.0),
        new Container(
          child: _buildComposer(),
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
        ),
      ]),
    );
  }


  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  onChanged: (String txt) {
                    setState(() {
                      _isWriting = txt.length > 0;
                    });
                  },
                  onSubmitted: _submitMsg,
                  decoration:
                  new InputDecoration.collapsed(hintText: "Enter some text to send a message"),
                ),
              ),
              new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 3.0),
                  child: IconButton(
                    icon: new Icon(Icons.message),
                    onPressed: _isWriting
                        ? () => _submitMsg(_textController.text)
                        : null,
                  )
              ),
            ],
          ),
      ),
    );
  }

  void _submitMsg(String txt) {

    _textController.clear();
    setState(() {
      _isWriting = false;
    });

    //Push message to firebase
    //Create message on the device
    //


    Msg msg = new Msg(
      message: txt,
      senderName: "TEST",
    );
    setState(() {
      _messages.insert(0, msg);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

}

class Msg extends StatelessWidget {
  Msg({this.message, this.senderName});
  final String message;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    return Row(

      children: <Widget>[



      ],

    );
//    return new SizeTransition(
//      sizeFactor: new CurvedAnimation(
//          parent: animationController, curve: Curves.easeOut),
//      axisAlignment: 0.0,
//      child: new Container(
//        margin: const EdgeInsets.symmetric(vertical: 8.0),
//        child: new Row(
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            new Container(
//              margin: const EdgeInsets.only(right: 18.0),
//              child: new CircleAvatar(child: new Text(senderName[0])),
//            ),
//            new Expanded(
//              child: new Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  new Text(senderName, style: Theme.of(ctx).textTheme.subhead),
//                  new Container(
//                    margin: const EdgeInsets.only(top: 6.0),
//                    child: new Text(message),
//                  ),
//                ],
//              ),
//            ),
//          ],
//        ),
//      ),
//    );
  }
}