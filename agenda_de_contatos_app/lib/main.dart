import 'package:flutter/material.dart';
import 'package:agenda_de_contatos/ui/HomePage.dart';

String _title = "Agenda de contatos";

void main(){
  runApp(
    MaterialApp(
      title: _title,
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}