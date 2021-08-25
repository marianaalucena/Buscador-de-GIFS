
import 'package:flutter/material.dart';
import 'package:buscador_de_gifs/ui/home_page.dart';

void main(){
  runApp(MaterialApp(
    //como tem varias paginas ele cria arquivos diferentes
    home: HomePage(),
    theme: ThemeData(hintColor: Colors.white),
  ));
}


