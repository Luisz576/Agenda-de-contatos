import 'dart:io';
import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

String _title = "Agenda de contatos";
enum OrderOptions{orderAZ, orderZA}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = new ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderAZ,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderZA,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text(
          _title,
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add, color: Colors.white,),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index){
          return cardBuilder(context, contacts[index]);
        },
      ),
    );
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderAZ:
        contacts.sort((a, b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      break;
      case OrderOptions.orderZA:
        contacts.sort((a, b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
      break;
    }
    setState(() {});
  }

  Widget cardBuilder(BuildContext context, Contact contact){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: contact.img != null ? FileImage(File(contact.img)) : AssetImage("images/person.png"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contact.name ?? "",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contact.phone ?? "",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contact.email ?? "",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, contact);
      },
    );
  }

  void _showOptions(BuildContext context, Contact contact){
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Ligar para ${contact.name}", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: (){
                        launch("tel:${contact.phone}");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Editar ${contact.name}", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: (){
                        Navigator.pop(context);
                        _showContactPage(contact: contact);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Excluir ${contact.name}", style: TextStyle(color: Colors.red, fontSize: 20.0),),
                      onPressed: () => _deleteContact(contact),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  _deleteContact(Contact contact){
    showDialog(
        context: context,
      builder: (context){
        return AlertDialog(
          title: Text("Deletar ${contact.name}?"),
          content: const Text("Não será possivel recuperar caso continue!"),
          actions: <Widget>[
            FlatButton(
              child: const Text("Cancelar"),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: const Text("Continuar"),
              onPressed: (){
                setState(() {
                  helper.deleteContact(contact.id);
                  contacts.remove(contact);
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      }
    );
  }

  void _showContactPage({Contact contact}) async{
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
              contact: contact,
            )
        )
    );
    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact);
      }else{
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState((){
        contacts = list;
      });
    });
  }

}