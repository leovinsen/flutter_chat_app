import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/util/firebase_handler.dart' as firebaseHandler;

class ChatScreen extends StatefulWidget {
  final String userPublicId;
  final UserData contactModel;
  ChatScreen({this.userPublicId, this.contactModel});
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<MessageBubble> _messages = <MessageBubble>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;
  String _chatUID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chatUID = firebaseHandler.getChatUID(widget.userPublicId, widget.contactModel.publicId);
  }

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
              title: new Text(widget.contactModel.displayName),
            ),
            elevation: 6.0,
          ),
          body: new Column(children: <Widget>[
            new Flexible(
                child: FirebaseAnimatedList(
                  reverse: true,
                  sort: (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key),
                  query: firebaseHandler.queryMessagesOrderByTimeAscending(_chatUID),
                  itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index){
                    return MessageBubble(
                      message: snapshot.value['message'],
                      sender: snapshot.value['sentBy'] == widget.userPublicId ? MessageSender.user : MessageSender.contact,
                    );
                  },

                )
            ),
            SizedBox(height:5.0),
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
                  textCapitalization: TextCapitalization.sentences,
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

    MessageBubble msg = new MessageBubble(
      message: txt,
      sender: MessageSender.user,
    );

    firebaseHandler.insertChatMessage(widget.userPublicId, widget.contactModel.publicId, txt);

    setState(() {
      _messages.insert(0, msg);
      //_messages.insert(0,msg2);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

}

enum MessageSender{
  user,
  contact
}

class MessageBubble extends StatelessWidget {

  MessageBubble({this.message, this.sender});
  final String message;
  final MessageSender sender;

  @override
  Widget build(BuildContext context) {
    double width80 = MediaQuery.of(context).size.width*0.8;
    double topMargin = sender == MessageSender.user ? 2.0 : 8.0;

    return Row(
      mainAxisAlignment: sender == MessageSender.user ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Card(
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: topMargin, bottom: 2.0),
          color: sender == MessageSender.user ? Theme.of(context).accentColor.withOpacity(0.5) : Colors.white,
          child: Container(
            constraints: BoxConstraints(maxWidth: width80),
            padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(message),
                ],
              )
          ),

        )

      ],

    );
  }
}