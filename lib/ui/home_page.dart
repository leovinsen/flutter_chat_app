import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/ui/add_contact_screen.dart';
import 'package:flutter_chat_app/ui/chat_tab.dart';
import 'package:flutter_chat_app/ui/contacts_tab.dart';
import 'package:flutter_chat_app/ui/profile_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:scoped_model/scoped_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageNewState createState() => _HomePageNewState();
}

class _HomePageNewState extends State<HomePage> {

  AppData appData;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);


    appData = AppData.of(context);
    appData.initSubscriptions();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage notif');
        print(message);
        await flutterLocalNotificationsPlugin.show(
            0, message['notification']['title'], message['notification']['body'], platformChannelSpecifics,
            payload: 'item id 2');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("TOKEN: $token");
    });
  }

  @override
  void dispose() {
    super.dispose();
    appData.cancelSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppData>(
      builder: (context, child, model) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text('Chat App'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.person_add),
                  onPressed: addContact,
                ),

                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {

                    ///TODO : FIX SIGN OUT
                    print('signout plceholder');
                    model.signOut();
                  },
                )
              ],

              bottom: TabBar(
                tabs: <Widget>[
                  Tab(child: Text('CHATS'),),
                  Tab(child: Text('CONTACTS'),),
                  Tab(child: Text('PROFILE'),)
                ],
              ),
            ),

            body: TabBarView(
              children: <Widget>[
                ChatTab(),
                ContactsTab(),
                ProfileScreen()
              ],
            ),
          ),
        );
      },
    );
  }

  void addContact() async {
    final results = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => AddContactScreen())
    );
  }
//    if (results != null) {
//      var model = AppData.of(context);
//      FirebaseDatabase db = FirebaseDatabase.instance;
//
//      String contactPublicId = results.toString().toLowerCase();
//
//      bool exist = await db.reference().child(
//          'userContacts/${model.userPublicId}/$contactPublicId').once().then((
//          snapshot) {
//        return snapshot.value != null;
//      });
//
//      if (exist) {
//        //TELL USER THE CONTACT EXISTS ALREADY
//        print('Contact Exists alrd');
//      } else {
//        //Push contact to firebase
//        db.reference().child('usersContact/${model.userPublicId}/$contactPublicId}')
//            .push()
//            .set(contactPublicId);
//      }
//    }



}
