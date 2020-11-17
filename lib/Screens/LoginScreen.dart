import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hellome/Screens/HomeScreen.dart';
import 'package:hellome/UserRaspitory.dart';
import 'package:hellome/Screens/UserHomeScreen.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

//----------------------------------------------------------------------------//

class LoginPage extends StatefulWidget {
  final Set<WordPair> saved;
  LoginPage({Key key,@required this.saved}): super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextEditingController _email;
  TextEditingController _password;
  TextEditingController password2;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _key = GlobalKey<ScaffoldState>();
  bool flag = true;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: "");
    _password = TextEditingController(text: "");
    password2 = TextEditingController(text: "");
  }


  String validatePassword(String value1,String v2,bool f) {
    if (!f && value1!=v2) {
      return "Passwords must match";
    }
    return null;
  }

  void snappingSheet(UserRepository user){
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return
          Form(
         key: _formKey2,
            child:
            Container(
              height: 200,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Please confirm your password bellow: '),
                  TextFormField(
                    controller: password2,
                    style: style,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: "Password",
                        border: OutlineInputBorder(),
                        errorText: validatePassword(password2.text,_password.text,flag),
                    ),
                    obscureText: true,
                  ),

                RaisedButton(
                  onPressed: () async {
                    flag = false;
                   if (_formKey.currentState.validate()) {
                      if(_password.text == password2.text){
                        try{
                        await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _email.text, password: password2.text);}
                          catch (e) {print(e);}
                          await user.signIn(_email.text, _password.text);
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => RandomWords2(
                                Userfav: widget.saved.toList(),
                                Usr: user,
                                Email: _email.text.toString(),)
                          ),);
                      }
                    }
                  },
                  color: Colors.teal,
                  child: const Text('Confirm'),
                ),
              ],
            ),
        )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Login Screen"),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _email,
                  style: style,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      labelText: "Email",
                      border: OutlineInputBorder()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: _password,
                  style: style,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      labelText: "Password",
                      border: OutlineInputBorder()),
                ),
              ),
              user.status == Status.Authenticating
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.red,
                  child: MaterialButton(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        if (!await user.signIn(_email.text, _password.text)){
                          _key.currentState.showSnackBar(SnackBar(
                            content: Text("There was an error logging into the app"),)
                          );
                        }
                        else{
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RandomWords2(
                                  Userfav: widget.saved.toList(),
                                  Usr: user,
                                  Email: _email.text.toString(),)
                            ),
                          );
                        }
                      }
                    },
                    child: Text(
                      "Log in",
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Text(" "),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(30.0),
                  color: Colors.teal,
                  child: MaterialButton(
                    onPressed: () async {
                      // await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      //     email: _email.text, password: _password.text);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => RandomWords2(
                      //         Userfav: widget.saved.toList(),
                      //         Usr: user,
                      //         Email: _email.text.toString(),)
                      //   ),
                      // );
                      snappingSheet(user);
                    },
                    child: Text(
                      "New user? Click to sign up",
                      style: style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
