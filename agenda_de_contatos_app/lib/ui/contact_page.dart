import 'dart:io';
import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();

}

class _ContactPageState extends State<ContactPage> {

  bool _userEdited = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();
  Contact _editedContact;

  @override
  void initState() {
    super.initState();
    if(widget.contact == null){
      _editedContact = new Contact();
    }else{
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _requestPop(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editedContact.name ?? "Novo contato"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editedContact.name != null && _editedContact.name.isNotEmpty){
              Navigator.pop(context, _editedContact);
            }else{
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save, color: Colors.white),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _editedContact.img != null ? FileImage(File(_editedContact.img)) : AssetImage("images/person.png"),
                    ),
                  ),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.gallery).then((arq){
                    if(arq == null){
                      return;
                    }else{
                      setState(() {
                        _editedContact.img = arq.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                focusNode: _nameFocus,
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nome",
                ),
                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.email = text;
                },
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Telefone",
                ),
                keyboardType: TextInputType.phone,
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.phone = text;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop(){
    if(_userEdited){
      showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Descartar alterações"),
            content: Text("Se sair as alterações serão perdidas"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Continuar"),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
      );
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

}