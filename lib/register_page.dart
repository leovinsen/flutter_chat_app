import 'package:flutter/material.dart';
import 'package:flutter_chat_app/app_model.dart';
import 'package:flutter_chat_app/auth.dart';
import 'package:scoped_model/scoped_model.dart';

class RegisterPage extends StatefulWidget {
  static final String tag = 'register-page';
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static final _formKey2 = GlobalKey<FormState>();

  String _displayName;
  String _email;
  String _password;
  String _publicId;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final model = AppModel.of(context);


    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;

    final publicIdField = TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.none,
      autofocus: true,
      validator: (val) => val.isEmpty ? 'Enter a unique ID.' : null,
      onSaved: (val) => _publicId = val,
      decoration: InputDecoration(
          hintText: 'Username',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
    );

    final nameField = TextFormField(
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      autofocus: true,
      validator: (val) => val.isEmpty ? 'Please enter your name.' : null,
      onSaved: (val) => _displayName = val,
      decoration: InputDecoration(
          hintText: 'Display Name',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(30.0))),
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
          OutlineInputBorder(borderRadius: BorderRadius.circular(35.0))),
    );

    final registerButton = Material(
      borderRadius: BorderRadius.circular(30.0),
      //shadowColor: Theme.of(context).accentColor,
      elevation: 1.0,
      child: MaterialButton(
        minWidth: 200.0,
        height: 45.0,
        color: Colors.lightBlueAccent,
        child: isLoading
            ? CircularProgressIndicator()
            : Text('Register',
          style: TextStyle(color: Colors.white, fontSize: 17.0),
        ),
        onPressed: () => _handleRegister(model),
      ),
    );

    final double formSpacing = 13.0;
    final form = Form(
      key: _formKey2,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        shrinkWrap: true,
        children: <Widget>[
          publicIdField,
          SizedBox(height: formSpacing),
          nameField,
          SizedBox(height: formSpacing),
          emailField,
          SizedBox(height: formSpacing),
          passwordField,
          SizedBox(height: 20.0),
          registerButton
        ],

      ),
    );

    final returnButton = Container(
      width: width,
      alignment: Alignment.center,
      child: FlatButton(
        child: new RichText(
          text: new TextSpan(
            text: "Already have an account?",
            style: TextStyle(
                fontSize: 15.0, color: Colors.black, fontFamily: 'Nunito'
            ),
            children: <TextSpan>[
              new TextSpan(text: ' Sign in.',
                  style: new TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        //Text("Register a New Account", style: TextStyle(fontSize: 16.0, color: Colors.black54),),
        onPressed: () => model.moveToLogin(),
      ),
    );


    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            child: form,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Divider(color: Colors.black, height: 5.0,),
              returnButton,
              SizedBox(height: 3.0,)
            ],
          )

        ],


      ),
    );
  }

  _handleRegister(AppModel model) async {
    final form = _formKey2.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        isLoading = true;
      });
      model.register(_email, _password, _displayName, _publicId)
          .then((status) {
        switch (status) {
          case SignInStatus.invalidEmail:
            createDialog(context, 'Invalid Email.',
                'The username does not appear to belong to an account. Please check your username and try again.');
            break;
          case SignInStatus.invalidPassword:
            createDialog(context, 'Invalid Password.',
                'The password you entered is invalid. Please try again.');
            break;
        }

//      try{
//        String userId = await model.auth.createUser(_email, _password);
//        print('Created user with id: $userId');
//        model.moveToLogin();
//
//      }catch (e){
//        String err = e.toString();
//        print(e);
//        if(err.contains('The email address is already in use by another account.')) print("Email is taken");
//      }


      });
    }
  }

  void createDialog(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],

          );
        }
    );
  }
}