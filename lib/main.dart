import 'package:flutter/material.dart';
import 'package:buscador_gifs/ui/HomePage.dart';
import 'package:buscador_gifs/ui/gif_page.dart';

void main(){
  runApp(MaterialApp(
    home: const HomePage(),
    theme: ThemeData(hintColor: Colors.white),
  ));
}