import 'package:flutter/material.dart';
import 'package:flutter_chat_app/model/app_data.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageNewState createState() => _LoginPageNewState();
}

enum FormType {
  login,
  register
}

class _LoginPageNewState extends State<LoginPage> {
  static final formKey = GlobalKey<FormState>();
  final double buttonRoundness = 16.0;
  bool loggingIn = false;
  FormType _formType = FormType.login;
  String _email;
  String _password;

  void _handleSubmit() async {
    AppData data = AppData.of(context);
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();

      setState(() {
        loggingIn= true;
      });

      try {
        switch (_formType) {
          case FormType.login:
            await data.signIn(_email, _password);
            break;

          case FormType.register:
            await data.registerNew(_email, _password);
            break;
        }
      } catch (e) {

        var arr = e.toString().split(',');
        print(arr[1]);
        print(arr.toString());
        createDialog(context, 'Error', arr[1].trim());
      } finally {
        setState(()=>  loggingIn = false);
      }
    }
  }

  void createDialog(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (_){
          return AlertDialog(
            title: Text(title),
            content: Text(content),
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

