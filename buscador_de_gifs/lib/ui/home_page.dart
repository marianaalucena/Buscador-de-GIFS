import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    //obtendo os dados
    if (_search == null) {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=qyxwJMx2OnF4YmBZMMLmbrfjBwbp579K&limit=20&rating=g");
    } else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=qyxwJMx2OnF4YmBZMMLmbrfjBwbp579K&q=$_search&limit=19&offset=$_offset&rating=g&lang=pt");
    }

    @override
    void initState() {
      super.initState();

      _getGifs().then((map) {
        print(map);
      });
    }

    //retorna no futuro
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        //Image.network: pega a imagem da internet
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-8974b8ae658f704a5b48a2d039b8ad93.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              //onSubmitted: chama a funcao quando pega o texto e pesquisa no teclado
              onSubmitted: (text) {
                //com essa pesquina o future builder vai se reconstruir, de acordo com a pesquisa
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
            ),
          ),

          //Expanded: para ocupar a tela toda
          Expanded(
            //FutureBuilder: reconstroi a tela, seja para pegar os melhores gifs ou pela pesquisa
            child: FutureBuilder(
              future: _getGifs(),
              //barra de carregamento
              builder: (context, snapshot) {
                //da uma olhada no estado da conexao
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        //AlwaysStoppedAnimation: animacao sempre parada
                        //especificando a cor do indication
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        //largura do circulo que ficara girando
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  //carregando mais gifs
  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

//tabela de gifs
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    //GridView: view que mostra em formato de grade
    return GridView.builder(
      //padding: distancia das laterais
      padding: EdgeInsets.all(10.0),
      //gridDelegate: mostra como os itens serao organizados na tela
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //crossAxisCount: quantos itens na horizontal
        crossAxisCount: 2,
        //crossAxisSpacing: espacamento entre os itens
        crossAxisSpacing: 10.0,
        //mainAxisSpacing: espacamento na vertical
        mainAxisSpacing: 10.0,
      ),
      //itemCount: quantidade de gifs que colocara na tela
      itemCount: _getCount(snapshot.data["data"]),
      //itemBuilder: funcao que retornara um widget que sera colocado em cada posicao
      itemBuilder: (context, index) {
        //
        if (_search == null || index < snapshot.data["data"].length) {
          //saber em qual posicao vai colocar o item
          //GestureDetector: para ser possivel clicar na imagem
          return GestureDetector(
            //verifica o json de requisicao
            //FadeInImage.memoryNetwork: mostrando as imagens de forma mais suaves, as imagens vao aparecendo gradativamente
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              //navegando entre as paginas
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GifPage(snapshot.data["data"][index]),
                ),
              );
            },
            onLongPress: () {
              Share.share(snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"]);
            },
          );
        } else {
          //quando eh o ultimo item mostra o icone para carregar + gifs
          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.add, color: Colors.white, size: 70.0),
                  Text(
                    "Carregar mais...",
                    style: TextStyle(color: Colors.white, fontSize: 22.0),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  //carregando mais 19 itens
                  _offset += 19;
                });
              },
            ),
          );
        }
      },
    );
  }
}
