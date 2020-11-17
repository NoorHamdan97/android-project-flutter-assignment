
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hellome/Screens/SavedSuggestionsScreen.dart';
import 'package:hellome/Screens/HomeScreen.dart';
import 'package:hellome/UserRaspitory.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'SavedSuggestionsScreen.dart';
//import 'package:image_picker/image_picker.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:path/path.dart';

class RandomWords2 extends StatefulWidget {
  final List<WordPair> Userfav; //before signing in
  final UserRepository Usr;
  final String Email;
  RandomWords2({Key key,@required this.Userfav,@required this.Usr,@required this.Email}): super(key: key);
  @override
  RandomWordsState createState() => RandomWordsState();
}


class RandomWordsState extends State<RandomWords2> {
  final List<WordPair> _suggestions = <WordPair>[];
  Map userDB;
  List userList;
  bool flag = true;
  //PlatformFile avatar;
  String _uploadedFileURL;
  //FileType _fileTyp= FileType.image;
  final _saved = Set<WordPair>(); //the words saved after
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  CollectionReference ref = FirebaseFirestore.instance.collection("Users");

  Future<void> fetch () async {
    var ID = widget.Email;
     Future<DocumentSnapshot> DS = ref.doc(ID).get();
     DS.then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        userDB=documentSnapshot.data(); // user DB is of type Map
        userList= userDB.containsKey('Saved')?List.from(userDB['Saved']):null;
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  Future<void> saveUserState() async {
    Set<WordPair> toSend = _saved;
    int len = widget.Userfav.length;
    for(int i =0;i<len;i++ ){
      toSend.add(widget.Userfav[i]);
    }
    int size = toSend.length;
    List<String> toAdd  = new List(size);
    for(int i=0; i<size; i++){
      toAdd[i]= toSend.toList()[i].asPascalCase;
    }
    Map<String, dynamic> data = {
      "Saved" : toAdd
    };
    var ID = widget.Email;
    await ref.doc(ID).set(data);
    widget.Usr.signOut();
  }

  //  void changeAvatar() async {
  //    FilePickerResult result;
  //    try{
  //    result = await FilePicker.platform.pickFiles();
  //    } catch(e){
  //      Scaffold.of(context).showSnackBar(SnackBar(
  //          content: Text("file picker bad")));
  //    }
  //    if(result != null) {
  //      avatar= result.files.first;
  //      _uploadedFileURL=result.files.first.path;
  //    }
  //    else {
  //      Scaffold.of(context).showSnackBar(SnackBar(
  //          content: Text("No image picked")));
  //    }
  // }


  @override
  Widget build(BuildContext context) {
    fetch ();
    return Scaffold (
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
          IconButton(icon: Icon(Icons.logout),onPressed:(){
            saveUserState();
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => RandomWords()),);}
          ),
        ],
      ),

      body:Stack(
          children:<Widget>[
            _buildSuggestions(),
      SnappingSheet(
        sheetBelow: SnappingSheetContent(
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
              Padding(
              padding: const EdgeInsets.all(8.0)),
                  Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(4.0)),
                      CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Text('AV'),
                        radius: 40.0,
                      ),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0)),
                  Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0)),
                      Text(widget.Email,
                      style: _biggerFont),
                      RaisedButton(
                        color: Colors.teal,
                        child: Text("Change avatar"),
                        onPressed:(){
                          final SnackBar s = SnackBar(content: Text("No image selected"));
                          Scaffold.of(context).showSnackBar(s);
                        }),
                    ],
                  )
                ],
              ),
            ),
            heightBehavior: SnappingSheetHeight.fit(),
      ),

      grabbing: Container(
        child: Row(children: [
        Padding(
        padding: const EdgeInsets.all(10.0)),
        Text(" Welcome back, "),
        Text(widget.Email),
        Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(Icons.arrow_drop_up))
          ],),
        color: Colors.grey,
      ),
    ),
          ],
      ),
    );
  }

  // void changeAvatar(){
  // }

  void _pushSaved() {
    Set<WordPair> toSend = _saved;
    if (flag) {
      int len = (widget.Userfav == null) ? -1 : widget.Userfav.length;
      for (int i = 0; i < len; i++) {
        toSend.add(widget.Userfav[i]);
      }
      (userList == null) ? len = -1 : len = userList.length;
      for (int j = 0; j < len; j++) {
        WordPair pair = WordPair(userList[j].toString()," ");
        toSend.add(pair);
      }
      flag = false;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            body: Builder(
                builder: (context) => SavedS(fav: toSend)
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing:new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (BuildContext _context, int i) {
          if (i.isOdd) {
            return Divider();
          }
          final int index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10).toList());
          }
          return _buildRow(_suggestions[index]);
        }
    );
  }
}