import 'package:flutter/material.dart';
import 'package:flutter_chat_app/data/repository.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/ui/home_page.dart';
import 'package:flutter_chat_app/ui/login/additional_info_screen.dart';
import 'package:flutter_chat_app/ui/login/login_page.dart';



class RootPage extends StatefulWidget {
  //RootPage({Key key, this.auth}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}


class _RootPageState extends State<RootPage> {
  final String tag = 'root-page';
//  final BaseAuth auth = Auth();

  String _uniqueAuthId;
//  String _publicId;
  AuthStatus _authStatus;
  bool isAuthenticating = true;

  @override
  initState() {
    super.initState();
    authenticate();
  }

  authenticate() async {
    Repository.get().authenticate().then((status){
      setState(() {
        _authStatus = status;
        isAuthenticating = false;
      });
    });
//    String Repository.get()
//    Auth.instance.authenticate().then((authStatus){
//      setState(() {
//        _authStatus = authStatus;
//        isAuthenticating = false;
//      });
//    });
  }

  void _signIn() {
    setState(() {
      isAuthenticating = true;
    });
    authenticate();
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
    print('calling build ROOT_PAGE');
    if (isAuthenticating) {
      return _loadingScreen();
    } else {
      switch (_authStatus) {
        case AuthStatus.notSignedIn:
          return LoginPage(
            //auth: auth,
            onSignIn: _signIn,
          );

        case AuthStatus.incompleteRegistration:
          return AdditionalInfoScreen(_uniqueAuthId, () {
            setState(() {

            });
          });
        case AuthStatus.signedIn:
          //AppData.of(context).initUserModel(_publicId);
          return HomePage(
            onSignOut: () => _signOut(),
          );
      }
    }
  }

  Widget _loadingScreen(){
    return Container(
        color: Theme
            .of(context)
            .primaryColor,
//        padding: const EdgeInsets.all(10.0),
//        alignment: Alignment.center,
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.end,
//          children: <Widget>[
//
//            SizedBox(
//                height: 60.0,
//                width: 60.0,
//                child: CircularProgressIndicator(
//                  strokeWidth: 4.0,
//                )),
//            SizedBox(height: 50.0),
//            Text('Signing In...')
//
//          ],
//        )
    );
  }

}
