import 'package:flutter/material.dart';
import 'package:share/share.dart';

//como nada muda nessa tela ela eh do tipo stateless
class GifPage extends StatelessWidget {

  //dados do gif que sera mostrado
  final Map _gifData;

  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_gifData["title"]),
        backgroundColor: Colors.black,
        actions: <Widget>[
          //botao de compartilhamento
          IconButton(
              icon: Icon(Icons.share),
              onPressed: (){
                //share: plugin de compartilhamento no flutter
                Share.share(_gifData["images"]["fixed_height"]["url"]);
              },),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(_gifData["images"]["fixed_height"]["url"]),
      )
    );
  }
}