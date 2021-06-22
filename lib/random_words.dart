import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';


class RandomWords extends StatefulWidget {
  final WordPairStorage storage;
  RandomWords({Key? key, required this.storage}) : super(key: key);
   
  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords>{
  final _randomWordPairs = <WordPair>[];
  final _savedWordPairs = Set<WordPair>();


  Widget _buildList() {
    return ListView.builder(
    padding: const EdgeInsets.all(16.0),
    itemBuilder: (context, item) {
      if(item.isOdd) return Divider();

      final index = item ~/ 2;

      if (index >= _randomWordPairs.length) {
        _randomWordPairs.addAll(generateWordPairs().take(10));
      }

      return _buildRow(_randomWordPairs[index]);
    }
  );
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _savedWordPairs.contains(pair);
  
    return ListTile(
      title: Text(pair.asPascalCase, 
                  style: TextStyle(fontSize: 18.0)),
      trailing: Icon(
                  alreadySaved ? Icons.favorite : Icons.favorite_border, 
                  color: alreadySaved ? Colors.red : null),
      onTap: () {
        setState(() {
          if(alreadySaved) {
            _savedWordPairs.remove(pair);
          } else {
            _savedWordPairs.add(pair);
          }
          
          final _tobeSaved = Set();

          for( var wp in _savedWordPairs) {
            _tobeSaved.add(wp.first+ '*' +wp.second);
          }
          
          widget.storage.writeWordPair(_tobeSaved);

        }
        );
      }
    );
  }

  void _pushedSaved() {
    widget.storage.readWordPair().then((value) {
      // final _previousWordPairs = value;
      _savedWordPairs.addAll(value);


      // print(value);
      Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _savedWordPairs.map((WordPair pair) {
            return ListTile(
            title: Text(pair.asPascalCase, 
            style:TextStyle(fontSize: 16.0))
            );
          });
            // print(tiles);


          final List<Widget> divided = ListTile.divideTiles(
            context:context,
            tiles: tiles
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title:Text('Saved WordPair')
            ),
            body: ListView(children: divided)

          );
        } 
      )
    );
    
    });
    
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: 
        AppBar(
          title: Text('WordPair Generator'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.list),
              onPressed: _pushedSaved,  
            )
          ]
        ),
        body: _buildList()
    );
  }
}

class WordPairStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<Set<WordPair>> readWordPair() async {
    final _toExport = Set<WordPair>();
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();
      // print(contents);
      final contentslist = contents.split(',');
      for (var i=0; i < contentslist.length; i++) {
        var wordPairInt = contentslist[i].split("*");
        _toExport.add(WordPair(wordPairInt[0],wordPairInt[1]));
      }
      // print(_toExport);

      return _toExport;
    } catch (e) {
      // If encountering an error, return 0
      // print(e);
      // print('{"No word saved"}');
      return _toExport;
    }
  }

  Future<File> writeWordPair(Set wordPair) async {
    final file = await _localFile;

    // Write the file
    // print(wordPair);
    final stringPair = wordPair.toList().join(',');
    // print(stringPair);
    return file.writeAsString(stringPair);
  }
}



// class RandomWordsState extends State<RandomWords>{
//   final _randomWordPairs = <WordPair>[];
//   final _savedWordPairs = Set<WordPair>();

//   Widget _buildList() {
//     return ListView.builder(
//     padding: const EdgeInsets.all(16.0),
//     itemBuilder: (context, item) {
//       if(item.isOdd) return Divider();

//       final index = item ~/ 2;

//       if (index >= _randomWordPairs.length) {
//         _randomWordPairs.addAll(generateWordPairs().take(10));
//       }

//       return _buildRow(_randomWordPairs[index]);
//     }
//   );
//   }

//   Widget _buildRow(WordPair pair) {
//     final alreadySaved = _savedWordPairs.contains(pair);

//     return ListTile(
//       title: Text(pair.asPascalCase, 
//                   style: TextStyle(fontSize: 18.0)),
//       trailing: Icon(
//                   alreadySaved ? Icons.favorite : Icons.favorite_border, 
//                   color: alreadySaved ? Colors.red : null),
//       onTap: () {
//         setState(() {
//           if(alreadySaved) {
//             _savedWordPairs.remove(pair);
//           } else {
//             _savedWordPairs.add(pair);
//           }
//         }
//         );
//       }
//     );
//   }

//   void _pushedSaved() {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (BuildContext context) {
//           final Iterable<ListTile> tiles = _savedWordPairs.map((WordPair pair) {
//             return ListTile(
//               title: Text(pair.asPascalCase, 
//               style:TextStyle(fontSize: 16.0))
//             );
//           });

//           final List<Widget> divided = ListTile.divideTiles(
//             context:context,
//             tiles: tiles
//           ).toList();

//           return Scaffold(
//             appBar: AppBar(
//               title:Text('Saved WordPair')
//             ),
//             body: ListView(children: divided)

//           );
//         } 
//       )
//     );
//   }

//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: 
//         AppBar(
//           title: Text('WordPair Generator'),
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(Icons.list),
//               onPressed: _pushedSaved,  
//             )
//           ]
//         ),
//         body: _buildList()
//     );
//   }
// }