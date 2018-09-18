import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/auth.dart';
import 'package:flutter_chat_app/util/helper.dart' as helper;
import 'package:flutter_chat_app/model/cache_handler.dart';

class LoginPageNew extends StatefulWidget {
  final BaseAuth auth;
  final void Function(String) onSignIn;
  //final VoidCallback onSignIn;

  LoginPageNew({this.auth, this.onSignIn});

  @override
  _LoginPageNewState createState() => _LoginPageNewState();
}

enum FormType {
  login,
  register
}

class _LoginPageNewState extends State<LoginPageNew> {
  static final formKey = GlobalKey<FormState>();
  final double buttonRoundness = 16.0;
  bool loggingIn = false;
  FormType _formType = FormType.login;
  String _email;
  String _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:ListView(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            appLogo(context),
            SizedBox(height: 30.0),
            form(),
          ],
        )
      ),
      bottomNavigationBar: registerOrLoginButton(),
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

  Widget emailField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
      onSaved: (val) => _email = val,
      decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(buttonRoundness))),
    );
  }

  Widget passwordField() {
    return TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (val) {
        if (val.isEmpty) {
          return 'Password can\'t be empty.';
        } else if (val.length < 7) {
          return 'Password has to be >6';
        } else {
          return null;
        }
      },
      onSaved: (val) => _password = val,
      decoration: InputDecoration(
          hintText: 'Password',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(buttonRoundness))),
    );
  }

  Widget submitButton() {
    return ButtonTheme(
      minWidth: 200.0,
      height: 40.0,
      child: RaisedButton(
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(buttonRoundness)),
        child: loggingIn
            ? CircularProgressIndicator()
            : Text(
          _formType == FormType.login ? 'Log In' : 'Register',
          style: TextStyle(color: Colors.white, fontSize: 17.0),
        ),
        onPressed: () => _handleSubmit(),
        color: Colors.lightBlueAccent,
      ),
    );
  }

  Form form(){
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          emailField(),
          SizedBox(height: 8.0),
          passwordField(),
          SizedBox(height: 20.0,),
          submitButton(),
        ],
      ),
    );
  }

  Widget registerOrLoginButton(){
    String normalText;
    String boldText;
    switch(_formType){
      case FormType.login:
        normalText = 'Don\'t have an account?';
        boldText = ' Sign up now!';
        break;
      case FormType.register:
        normalText = 'Have an account already?';
        boldText = ' Sign in.';
        break;
    }
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Divider(height: 1.0, color: Colors.black,),
        FlatButton(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: RichText(
            text: TextSpan(
              text: normalText,
              style: TextStyle(
                  fontSize: 15.0, color: Colors.black,fontFamily: 'Nunito'
              ),
              children: <TextSpan>[
                new TextSpan(text: boldText, style: new TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ) ,
          onPressed: (){
            switch(_formType){
              case FormType.login:
                moveToRegister();
                break;
              case FormType.register:
                moveToLogin();
                break;
            }
          },
        ),
      ],
    );
  }

  void _handleSubmit() async {

    final form = formKey.currentState;
    if (form.validate()) {
      form.save();

      setState(() {
        loggingIn= true;
      });

      try {
        switch(_formType){
          case FormType.login:
            //String
            ResultMessage rm = await widget.auth.signIn(_email, _password);

            if(rm.code == ResultCode.success) widget.onSignIn(rm.message);
            else {
              createDialog(context, 'Error', rm.message);
            }

//            widget.auth.signIn(_email, _password).then((uniqueId){
//              widget.onSignIn(uniqueId);
//            });
            break;
          case FormType.register:
            widget.auth.createUser(_email, _password).then((uniqueId){
              CacheHandler.storeUserRegistrationStatus(false);
              widget.onSignIn(uniqueId);
              //Associate the unique ID generated by Firebase with Username chosen by the user.
              //Relationship is defined as uniqueID : publicID under /users/

              //helper.usersRef.child(uniqueId).set(publicId);

              //Create a record in /usersInfo/
              //Relationship is defined as publicID : UserModel.toJson()
              //userModel = UserModel();
              //userModel.displayName = displayName;
              //userModel.publicId = publicId;


              //usersInfoRef.child(publicId).set(userModel.toJson());

              //_uid = uniqueId;


              //_authStatus = AuthStatus.signedIn;
              //notifyListeners();
            });
            break;
        }
      } catch (e){
        print(e);
      }
    }
  }

  void createDialog(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (_){
          return AlertDialog(
            title: Text(title),
            content: Text(content) ,
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],

          );
        }
    );
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }


}

//final googleLoginButton = Material(
//  borderRadius: BorderRadius.circular(30.0),
//  //shadowColor: Theme.of(context).buttonColor,
//  elevation: 1.0,
//  child: MaterialButton(
//    minWidth: 200.0,
//    height: 45.0,
//    color: Colors.blueGrey,
//    child: Text(
//      'Log in with Google',
//      style: TextStyle(color: Colors.white, fontSize: 17.0),
//    ),
//    onPressed: () {},
//  ),
//);

