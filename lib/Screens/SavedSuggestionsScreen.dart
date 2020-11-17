import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

class SavedS extends StatefulWidget {
  final Set<WordPair> fav;
  SavedS({Key key,@required this.fav}): super(key: key);
  @override
  _SavedSState createState() => _SavedSState();
}

class _SavedSState extends State<SavedS> {
  Widget _buildRow(WordPair pair) {
    return ListTile(
      title: Text(
        pair.asPascalCase,
      ),
      trailing: Icon(
        Icons.delete,
        color:Colors.red,
      ),
      onTap: () {
        setState(() {
          widget.fav.remove(pair);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Saved Suggestions'),
        ),
        body: new ListView.builder(
            itemCount: widget.fav.length,
            itemBuilder: (context, int i) {
              return _buildRow(widget.fav.toList()[i]);
            }
        )
    );
  }
}
