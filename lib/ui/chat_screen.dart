import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/model/user_data.dart';
import 'package:flutter_chat_app/widgets/circular_profile_image.dart';

import '../util/dimensions.dart' as dimen;

class ChatScreen extends StatefulWidget {
  final String userPublicId;
  final UserData contactModel;

  ChatScreen({this.userPublicId, this.contactModel})
      : assert(userPublicId != null),
        assert(contactModel != null);

  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<MessageBubble> _messages = <MessageBubble>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  @override
  void initState() {
    super.initState();
    AppData appData = AppData.of(context);
    appData.refreshUserDataFor(widget.contactModel.publicId);

    ///Refresh contact Model
  }

  void _submitMsg(String txt) {
    _textController.clear();
    AppData appData = AppData.of(context);

    setState(() {
      _isWriting = false;
    });

    MessageBubble msg = MessageBubble(
      message: txt,
      sender: MessageSender.user,
    );

    String chatUID = determineChatUID(widget.userPublicId, widget.contactModel.publicId);

    appData.sendMessage(
        chatUID,
        widget.userPublicId,
        widget.contactModel.publicId, txt
    );

    setState(() {
      _messages.insert(0, msg);
    });
  }


  ///a simple unique ID generator
  String determineChatUID(String senderPublicId, String receiverPublicId) {
    return senderPublicId.hashCode <= receiverPublicId.hashCode
        ? '$senderPublicId-$receiverPublicId'
        : '$receiverPublicId-$senderPublicId';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: Column(children: <Widget>[
        _chatContainer(),
        SizedBox(height: 5.0),
        Divider(height: 1.0),
        _chatBox()
      ]),
    );
  }

  Widget _appBar() {
    return AppBar(
        elevation: 2.0,
        automaticallyImplyLeading: true, //false to hide back button
        title: _buildContactProfile());
  }

  Widget _buildContactProfile() {
    return Transform.translate(
      offset: Offset(-20.0, 0.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: <Widget>[
            CircularNetworkProfileImage(
              size: dimen.chatScreenBarCircleImageSize,
              url: widget.contactModel.thumbUrl,
              publicId: widget.contactModel.publicId,
            ),
            SizedBox(width: 12.0),
            Text(widget.contactModel.displayName)
          ],
        ),
      ),
    );
  }

  Widget _chatContainer() {
    return Flexible(
        child: Padding(
            padding: const EdgeInsets.all(8.0), child: _buildChatMessages()));
  }

  Widget _buildChatMessages() {

    String chatId = determineChatUID(widget.userPublicId, widget.contactModel.publicId);
    Query query = AppData.of(context).getChatMessageStream(chatId);
    if(query == null) print('query is nul');
    return FirebaseAnimatedList(
      reverse: false,
      sort: (a, b) => (a.value['messageTime'] as int).compareTo(b.value['messageTime']),
      query: query,
      itemBuilder: (_, DataSnapshot snapshot, Animation<double> animation, int index) {

        return MessageBubble(
          message: snapshot.value['message'],
          sender: snapshot.value['sentBy'] == widget.userPublicId
              ? MessageSender.user
              : MessageSender.contact,
        );
      },
    );
  }

  Widget _chatBox() {
    return Container(
      child: _buildComposer(),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
    );
  }

  Widget _buildComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 9.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                controller: _textController,
                onChanged: (String txt) {
                  setState(() {
                    _isWriting = txt.length > 0;
                  });
                },
                onSubmitted: _submitMsg,
                decoration: InputDecoration.collapsed(
                    hintText: "Enter some text to send a message"),
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 3.0),
                child: IconButton(
                  icon: Icon(Icons.message),
                  onPressed: _isWriting
                      ? () => _submitMsg(_textController.text)
                      : null,
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

enum MessageSender { user, contact }

class MessageBubble extends StatelessWidget {
  MessageBubble({this.message, this.sender});

  final String message;
  final MessageSender sender;

  @override
  Widget build(BuildContext context) {
    double width80 = MediaQuery.of(context).size.width * 0.8;
    double topMargin = sender == MessageSender.user ? 2.0 : 8.0;

    return Row(
      mainAxisAlignment: sender == MessageSender.user
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: <Widget>[
        Card(
          margin: EdgeInsets.only(
              left: 10.0, right: 10.0, top: topMargin, bottom: 2.0),
          color: sender == MessageSender.user
              ? Theme.of(context).accentColor.withOpacity(0.5)
              : Colors.white,
          child: Container(
              constraints: BoxConstraints(maxWidth: width80),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(message),
                ],
              )),
        )
      ],
    );
  }
}
