import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColunm = "idColunm";
final String nameColunm = "nameColunm";
final String emailColunm = "emailColunm";
final String phoneColunm = "phoneColunm";
final String imgColunm = "imgColunm";

class ContactHelper{

  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  Database _db;

  Future<Database> get db async{
    if(_db != null){
      return _db;
    }else{
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async{
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "contactsagenda.db");
    return await openDatabase(path, version: 1, onCreate: (Database database, int newerVersion) async{
      await database.execute(
          "CREATE TABLE $contactTable($idColunm INTEGER NOT NULL PRIMARY KEY, $nameColunm TEXT, $emailColunm TEXT, $phoneColunm TEXT, $imgColunm TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async{
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async{
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(
      contactTable,
      columns: [idColunm, nameColunm, emailColunm, phoneColunm, imgColunm],
      where: "$id = ?", //? <- No whereArgs voce passa os ?
      whereArgs: [id],
    );
    if(maps.length > 0){
      return Contact.fromMap(maps.first);
    }else{
      return null;
    }
  }

  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return await dbContact.delete(
      contactTable,
      where: "$idColunm = ?",
      whereArgs: [id],
    );
  }

  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: "$idColunm = ?",
      whereArgs: [contact.id],
    );
  }

  Future<List> getAllContacts() async{
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  close() async{
    Database dbContact = await db;
    dbContact.close();
  }

}

class Contact{

  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();//Construtor

  Contact.fromMap(Map map){
    id = map[idColunm];
    name = map[nameColunm];
    email = map[emailColunm];
    phone = map[phoneColunm];
    img = map[imgColunm];
  }

  Map toMap(){
    Map<String, dynamic> map = {
      nameColunm: name,
      emailColunm: email,
      phoneColunm: phone,
      imgColunm: img
    };
    if(id != null){
      map[idColunm] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }

}