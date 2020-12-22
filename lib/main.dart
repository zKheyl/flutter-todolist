import 'package:cloud_firestore/cloud_firestore.dart';
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
      title: 'Flutter Todolist',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        accentColor: Colors.green,
      ),
      home: ListsPage(title: 'Mes listes'),
    );
  }
}

class ListsPage extends StatefulWidget {
  ListsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListsPageState createState() => _ListsPageState();
}

class _ListsPageState extends State<ListsPage> {
  String input = "";
  String inputModifierTodo = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Mes listes')),
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
                title: Text("Ajouter une liste"),

                content: TextField(
                  onChanged: (String value) {
                    newValue = value;
                  },
                ),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Firestore.instance.collection('todolists').add({
                          'name': newValue,
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
      stream: Firestore.instance.collection('todolists').snapshots(),
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
    final record = ListRecord.fromSnapshot(data);

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
          trailing: Wrap(
            spacing: 30,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.delete,
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
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Modifier le nom de la liste "),
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TodosPage(record: record)),
            );
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


class TodosPage extends StatefulWidget {
  TodosPage({Key key, this.record}) : super(key: key);
  final ListRecord record;

  @override
  _TodosPageState createState() => _TodosPageState(record: record);
}

class _TodosPageState extends State<TodosPage> {
  _TodosPageState({this.record}) : super();
  final ListRecord record;
  String input = "";
  String inputModifierTodo = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text(record.name)),
        floatingActionButton: _floatingAddButton(),
        body: _buildBody(context, record.reference)
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

                            record.reference.collection('todos').add({
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

  Widget _buildBody(BuildContext context, DocumentReference reference) {
    return StreamBuilder<QuerySnapshot>(
      stream: reference.collection('todos').snapshots(),
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
    final record = TodoRecord.fromSnapshot(data);

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
              trailing: Wrap(
                spacing: 30,
                children: <Widget>[
                  Checkbox(value: record.checked, onChanged: (bool newValue) {
                    setState(() {
                     record.reference.updateData({'checked': newValue});
                    });
                  }),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
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
            onLongPress: () {},
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

class ListRecord {
  String name;
  String color;
  Timestamp dateFin;
  final DocumentReference reference;

  ListRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        //assert(map['color'] != null),
        //assert(map['date_fin'] != null),
        name = map['name'],
        color = map['color'],
        dateFin = map['date_fin'];

  ListRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$color:$dateFin>";
}

class TodoRecord {
  String name;
  final bool checked;
  final DocumentReference reference;

  TodoRecord.fromMap(Map<String, dynamic> map, {this.reference})

      : assert(map['name'] != null),
        assert(map['checked'] != null),
        name = map['name'],
        checked = map['checked'];

firebase-integration-ios
  TodoRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$checked>";
}