import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/app_model.dart';
import 'package:flutter_chat_app/register_page.dart';
import 'package:scoped_model/scoped_model.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {


//  LoginPage({Key key, this.title})
//      : super(key: key);

  static String tag = 'login-page';
  //final String title;
  //final BaseAuth auth;
  //final VoidCallback onSignIn;

  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType{
  login,
  register
}

class _LoginPageState extends State<LoginPage> {

  static final formKey = GlobalKey<FormState>();

  String _email;
  String _password;
  FormType _formType = FormType.login;
  String _authHint = "";

  @override
  Widget build(BuildContext context) {
    final model = AppModel.of(context);
    final logo = Image(
      image: AssetImage('assets/logo.png'),
      height: 128.0,
      width: 128.0,
      color: Theme.of(context).accentColor,
    );

    final emailField = TextFormField(
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
      onSaved: (val) => _email = val,
      decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (val) => val.isEmpty ? 'Password can\'t be empty.' : null,
      onSaved: (val) => _password = val,
      decoration: InputDecoration(
          hintText: 'Password',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(35.0))),
    );

    final loginButton = Material(
      borderRadius: BorderRadius.circular(30.0),
      //shadowColor: Theme.of(context).accentColor,
      elevation: 1.0,
      child: MaterialButton(
        minWidth: 200.0,
        height: 45.0,
        color: Colors.lightBlueAccent,
        child: Text(
          'Log In',
          style: TextStyle(color: Colors.white, fontSize: 17.0),
        ),
        onPressed: () async {
          formKey.currentState.validate();
          formKey.currentState.save();
          model.signInWithEmail(_email, _password)
              .then((status){
             switch(status){
               case SignInStatus.invalidEmail:
                 createDialog(context, 'Invalid Email.',
                 'The username does not appear to belong to an account. Please check your username and try again.');
                 break;
               case SignInStatus.invalidPassword:
                 createDialog(context, 'Invalid Password.',
                 'The password you entered is invalid. Please try again.');
                 break;
             }
          });
        },
      ),
    );

    final form = Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          emailField,
          SizedBox(height: 8.0),
          passwordField,
          SizedBox(
            height: 20.0,
          ),
          loginButton,
        ],
      ),
    );


    final middleDivider = Center(
      child: Text(
        'OR',
        style: TextStyle(fontSize: 16.0, color: Colors.grey),
      ),
    );

    final googleLoginButton = Material(
      borderRadius: BorderRadius.circular(30.0),
      //shadowColor: Theme.of(context).buttonColor,
      elevation: 1.0,
      child: MaterialButton(
        minWidth: 200.0,
        height: 45.0,
        color: Colors.blueGrey,
        child: Text(
          'Log in with Google',
          style: TextStyle(color: Colors.white, fontSize: 17.0),
        ),
        onPressed: () {},
      ),
    );

//    final registerAccountButton = Expanded(
//      child: Container(
//        alignment: Alignment.center,
//        child: FlatButton(
//          child: new RichText(
//            text: new TextSpan(
//              text: "Don't have an account?",
//              style: TextStyle(
//                fontSize: 15.0, color: Colors.black,fontFamily: 'Nunito'
//              ),
//              children: <TextSpan>[
//                new TextSpan(text: ' Sign up now!', style: new TextStyle(fontWeight: FontWeight.bold)),
//              ],
//            ),
//          ) ,
//          onPressed: (){
//            formKey.currentState.reset();
//            model.moveToRegister();
//          },
//        ),
//      ),
//    );


    return Scaffold(
      body: Column(
        children: <Widget>[
          Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              children: <Widget>[
                SizedBox(height: 100.0),
                logo,
                SizedBox(height: 30.0),
                form,
                SizedBox(height: 20.0,),
                middleDivider,
                SizedBox(height: 20.0,),
                googleLoginButton,
              ],
            ),
          ),
          SizedBox(height: 65.0),
//          Divider(height: 1.0, color: Colors.black,),
          //registerAccountButton
        ],
      ),

      bottomNavigationBar: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Divider(height: 1.0, color: Colors.black,),
          FlatButton(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: new RichText(
              text: new TextSpan(
                text: "Don't have an account?",
                style: TextStyle(
                    fontSize: 15.0, color: Colors.black,fontFamily: 'Nunito'
                ),
                children: <TextSpan>[
                  new TextSpan(text: ' Sign up now!', style: new TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ) ,
            onPressed: (){
              formKey.currentState.reset();
              model.moveToRegister();
            },
          ),
        ],
      ),

    );
  }

//  Future<SignInStatus> _handleSubmit(AppModel model) async {
//    final form = formKey.currentState;
//    if (form.validate()){
//      form.save();
//      return model.signInWithEmail(_email, _password);
//    }
//  }

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
}
