import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

final dummySnapshot = [
  {"name": "Filip", "votes": 15},
  {"name": "Abraham", "votes": 14},
  {"name": "Richard", "votes": 11},
  {"name": "Ike", "votes": 10},
  {"name": "Justin", "votes": 1},
];

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
  List todos = List();
  String input = "";
  String inputModifierTodo = "";
  List<bool> checkboxValue = new List<bool>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todos.add("test");
    todos.add("test2");
    todos.add("test3");
    todos.add("test4");

    checkboxValue.add(false);
    checkboxValue.add(false);
    checkboxValue.add(false);
    checkboxValue.add(false);
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Mes todos"),
    return Scaffold(
      appBar: AppBar(title: Text('Baby Name Votes')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('baby').snapshots(),
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

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          trailing: Text(record.votes.toString()),
          onTap: () => record.reference.updateData({'votes': FieldValue.increment(1)})
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Ajouter une tâche"),
                    content: TextField(
                      onChanged: (String value) {
                        input = value;
                      },
                    ),
                    actions: <Widget>[
                      FlatButton(onPressed: () {
                                    setState(() {
                                      todos.add(input);
                                      checkboxValue.add(false);
                                });
                                    Navigator.of(context).pop();
                      }, child: Text("Ajouter"))
                    ]
                  );
            });
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: ListView.builder(itemCount: todos.length,
            itemBuilder: (BuildContext context, int index){
              return Dismissible(key: Key(todos[index]),
                  direction: DismissDirection.startToEnd,
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(borderRadius:
                    BorderRadius.circular(8)),
                    child: ListTile(
                      title: Text(todos[index]),
                      trailing: Wrap(
                        spacing: 30,
                        children: <Widget>[
                          Checkbox(value: checkboxValue[index], onChanged: (bool newValue) {
                            setState(() {
                              checkboxValue[index] = newValue;
                            });
                          }),
                          IconButton
                            (icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),

                            onPressed: () {
                              setState(() {
                                todos.removeAt(index);
                                checkboxValue.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      onLongPress: () {

                      },
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  title: Text("Modifier le nom de la tâche "),
                                  content: TextField(
                                    onChanged: (String value) {
                                      input = value;
                                    },
                                  ),
                                  actions: <Widget>[
                                    FlatButton(onPressed: () {
                                      setState(() {
                                        todos[index] = input;
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
                    todos.removeAt(index);
                    checkboxValue.removeAt(index);
                  }
                },
              );
            }),
      );
      ),
    );
  }
}

class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['votes'] != null),
        name = map['name'],
        votes = map['votes'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$votes>";
}