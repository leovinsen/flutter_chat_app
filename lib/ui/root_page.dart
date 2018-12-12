import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/ui/home_page.dart';
import 'package:flutter_chat_app/ui/login/additional_info_screen.dart';
import 'package:flutter_chat_app/ui/login/login_page.dart';
import 'package:scoped_model/scoped_model.dart';



class RootPage extends StatefulWidget {
  //RootPage({Key key, this.auth}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}


class _RootPageState extends State<RootPage> {
  final String tag = 'root-page';

  AuthStatus _authStatus;
  bool isAuthenticating = true;

  @override
  initState() {
    super.initState();
//    init();
  }
//
//  init() async {
//
//     if(await Repository.get().loadUserInfo()){
//      _authStatus = AuthStatus.signedIn;
//      isAuthenticating = false;
//     } else {
//       authenticate();
//     }
//  }

//  authenticate() async {
//    Repository.get().authenticate().then((status){
//      setState(() {
//        _authStatus = status;
//        isAuthenticating = false;
//      });
//    });
//  }

  void _signIn() {
    setState(() {
      isAuthenticating = true;
    });
//    authenticate();
  }

  void updateAuthStatus(AuthStatus status){
    setState(() {
      _authStatus = status;
    });
  }

  void _signOut() {
    setState(() {
      Auth.instance.signOut();
      //AppData.of(context).cleanup();
      //CacheHandler.clearUserCreds();
      _authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppData>(
      builder: (context, child, model) {
        if (model.ready) {
          switch (model.status) {
            case AuthStatus.notSignedIn:
              return LoginPage(
                onSignIn: _signIn,
              );

            case AuthStatus.incompleteRegistration:
              return AdditionalInfoScreen();
            case AuthStatus.signedIn:
              return HomePage(
                onSignOut: () => _signOut(),
              );
            default:
              print('null');
              return _loadingScreen();
          }
        } else {
          return _loadingScreen();
        }
      }
    );

//    print('calling build ROOT_PAGE');
//    if (isAuthenticating) {
//      return _loadingScreen();
//    } else {
//      switch (_authStatus) {
//        case AuthStatus.notSignedIn:
//          return LoginPage(
//            //auth: auth,
//            onSignIn: _signIn,
//          );
//
//        case AuthStatus.incompleteRegistration:
//          return AdditionalInfoScreen(Repository.get().getUserPublicIdFromMemory(), authenticate);
//        case AuthStatus.signedIn:
//          //AppData.of(context).initUserModel(_publicId);
//          return HomePage(
//            onSignOut: () => _signOut(),
//          );
//      }
//    }
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
