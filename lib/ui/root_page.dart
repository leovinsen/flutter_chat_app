import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/ui/home_page.dart';
import 'package:flutter_chat_app/ui/login/additional_info_screen.dart';
import 'package:flutter_chat_app/ui/login/login_page.dart';
import 'package:scoped_model/scoped_model.dart';

class RootPage extends StatefulWidget {

  @override
  _RootPageState createState() => _RootPageState();
}


class _RootPageState extends State<RootPage> {
  final String tag = 'root-page';

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppData>(
      builder: (context, child, model) {
        if (model.ready) {
          switch (model.status) {
            case AuthStatus.notSignedIn:
              return LoginPage();
            case AuthStatus.incompleteRegistration:
              return AdditionalInfoScreen();
            case AuthStatus.signedIn:
              return HomePage();
            default:
              print('null');
              return _loadingScreen();
          }
        } else {
          return _loadingScreen();
        }
      }
    );
  }

  Widget _loadingScreen() {
    return Container(
      color: Theme
          .of(context)
          .primaryColor,
      child: appLogo(context),
    );
  }

  Widget appLogo(BuildContext context) {
    return Image(
      image: AssetImage('assets/logo.png'),
      height: 128.0,
      width: 128.0,
      color: Theme
          .of(context)
          .accentColor,
    );
  }

}
