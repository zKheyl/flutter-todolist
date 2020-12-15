import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.green,
      ),
      home: MyHomePage(title: 'ToDo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //List todos = List();
  String input = "";
  String inputModifierTodo = "";
  //List<bool> checkboxValue = new List<bool>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    /*todos.add("test");
    todos.add("test2");
    todos.add("test3");
    todos.add("test4");
    checkboxValue.add(false);
    checkboxValue.add(false);
    checkboxValue.add(false);
    checkboxValue.add(false);*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Mes todos')),
        floatingActionButton: _floatingAddButton(),
        body: _buildBody(context)
    );
  }

  Widget _floatingAddButton() {
    String newValue = '';
    return FloatingActionButton(
        onPressed: (){
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Ajouter une tâche"),
                content: TextField(
                  onChanged: (String value) {
                    newValue = value;
                  },
                ),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        //todos.add(input);
                        //checkboxValue.add(false);

                        Firestore.instance.collection('todos').add({
                          'name': newValue,
                          'checked': false
                        });
                      },
                      child: Text("Ajouter")
                  )
                ],
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        )
    );

  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('todos').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Dismissible(
      key: Key(record.name),
      direction: DismissDirection.startToEnd,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius:
        BorderRadius.circular(8)),
        child: ListTile(
          title: Text(record.name),
          leading: Checkbox(value: record.checked, onChanged: (bool newValue) {
            setState(() {
              record.reference.updateData({'checked': newValue});
            });
          }),
          trailing: Wrap(
            spacing: 30,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    record.reference.delete();
                  });
                },
              ),
            ],
          ),
          onLongPress: () {
            print("long press");
          },
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: Text("Modifier le nom de la tâche "),
                      content: TextField(
                        controller: TextEditingController()..text = record.name,
                        onChanged: (String value) {
                          record.reference.updateData({"name": value});
                        },
                      ),
                      actions: <Widget>[
                        FlatButton(onPressed: () {
                          setState(() {
                            record.name = input;
                          });
                          Navigator.of(context).pop();
                        }, child: Text("Modifier"))
                      ]
                  );
                });
          },
        ),
      ),
      onDismissed: (direction) {
        if(direction == DismissDirection.startToEnd){
          record.reference.delete();
        }
      },
    );
  }
}

class Record {
  String name;
  //final int votes;
  final bool checked;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['checked'] != null),
        name = map['name'],
        checked = map['checked'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$checked>";
}