import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:intl/intl.dart';

import 'flutter_tag_view.dart';


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
  DateTime inputDate;
  Timestamp dateAsTimeStamp;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Mes listes')),
        floatingActionButton: _floatingAddButton(),
        body: _buildBody(context));
  }

  DateTime selectedDate;
  DateFormat newFormat = DateFormat("dd.MM.yyyy");
  
  Widget _floatingAddButton() {
    String newValue = '';

    return FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Ajouter une liste"),
                content: Wrap(spacing: 20, runSpacing: 20, children: [
                  Text("Nom de la tâche"),
                  TextField(
                    onChanged: (String value) {
                      newValue = value;
                    },
                  ),
                  Text("Date limite"),
                  DateTimeFormField(
                    onDateSelected: (DateTime date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  )
                ]),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        FirebaseFirestore.instance.collection('todolists').add({ //liste de todo
                          'name': newValue,
                          'endDate': selectedDate
                        });
                      },
                      child: Text("Ajouter"))
                ],
              );
            },
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ));
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('todolists').snapshots(),
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
    List<String> tags = <String>[];
    String endDate = record.dateFin != null ? newFormat.format(DateTime.parse(record.dateFin.toDate().toString())) : '';

    if (record.tags != null){
      for(int i = 0; i < record.tags.length; i++){
        tags.add(record.tags[i].toString());
      }
    }

    TextEditingController _textController = new TextEditingController();

    return Dismissible(
      key: Key(record.name),
      direction: DismissDirection.startToEnd,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          title: Text(record.name),
          subtitle: Text(endDate), //Niveau List
          trailing: Wrap(
            spacing: 30,
            children: <Widget>[
              IconButton(
                icon: Icon(
                    Icons.label_outlined,
                    color: Colors.black,
                ),
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (BuildContext context)
                  {
                    return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                              title: Text("Modifier les tags"),
                              content:
                              Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  children: [
                                    FlutterTagView(
                                      tags: tags,
                                      maxTagViewHeight: 100,
                                      deletableTag: true,
                                      onDeleteTag: (i) {
                                        tags.removeAt(i);
                                        record.reference.update({"tags": tags});
                                        setState(() {});
                                      },
                                      /*tagTitle: FlutterTagView.tagTitle,*/
                                    ),
                                    TextField(
                                      controller: _textController,
                                      decoration: InputDecoration(
                                        hintText: 'Nouveau tag',
                                      ),
                                      onSubmitted: (String value) {
                                        tags.add(value);
                                        _textController.clear();
                                        setState(() {});
                                      },
                                    ),
                                  ]),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    if(_textController.text.toString() != ''){
                                      tags.add(_textController.text.toString());
                                      _textController.clear();
                                      setState(() {});
                                    }
                                  }, child: Text("Ajouter"))
                              ],
                          );
                      });
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Etes-vous sûr de vouloir supprimer la tâche ?"),
                          actions: <Widget>[
                            FlatButton(
                                color: Colors.red,
                                textColor: Colors.white,
                                child: Text("NON"),
                                onPressed: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                }),
                            FlatButton(
                                color: Colors.green,
                                textColor: Colors.white,
                                child: Text("OUI"),
                                onPressed: () {
                                  setState(() {
                                    record.reference.delete();
                                    Navigator.pop(context);
                                  });
                                })
                          ],
                        );
                      }
                  );
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
                    content:
                    Wrap(
                    spacing: 20,
                      runSpacing: 20,
                      children :[
                        TextField(
                          controller: TextEditingController()..text = record.name,
                          onChanged: (String value) {
                            record.reference.update({"name": value});
                          },
                        ),
                        Text("Date limite"),
                        DateTimeFormField(
                            initialValue: record.dateFin != null ? DateTime.parse(record.dateFin.toDate().toString()) : null,
                            onDateSelected: (DateTime date) {
                              setState(() {
                                selectedDate = date;
                                dateAsTimeStamp = Timestamp.fromDate(date);
                                record.reference
                                    .update({"endDate": dateAsTimeStamp});
                              });
                        })
                      ]
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
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Etes-vous sûr de vouloir supprimer la tâche ?"),
                actions: <Widget>[
                  FlatButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      child: Text("NON"),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      }),
                  FlatButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      child: Text("OUI"),
                      onPressed: () {
                        setState(() {
                          record.reference.delete();
                          Navigator.pop(context);
                        });
                      })
                ],
              );
            }
        );
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
  Timestamp inputDate;
  DateTime selectedDate;
  Timestamp dateAsTimeStamp;

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

                      content: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                        Text("Nom de la tâche"),
                        TextField(
                          onChanged: (String value) {
                            newValue = value;
                          },
                  ),
                  Text("Date limite"),
                  DateTimeFormField(
                    onDateSelected: (DateTime date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  )
                ]),
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        record.reference.collection('todos').add({
                              'name': newValue,
                              'checked': false,
                              'endDate': selectedDate
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
    DateFormat newFormat = DateFormat("dd.MM.yyyy");
    final record = TodoRecord.fromSnapshot(data);
    String endDate = record.endDate != null ? newFormat.format(DateTime.parse(record.endDate.toDate().toString())) : '';

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
              subtitle: Text(endDate), //Niveau tâche ?
              trailing: Wrap(
                spacing: 30,
                children: <Widget>[
                  Checkbox(value: record.checked, onChanged: (bool newValue) {
                    setState(() {
                     record.reference.update({'checked': newValue});
                    });
                  }),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                    showDialog(
                      context: context,
                        builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Etes-vous sûr de vouloir supprimer la tâche ?"),
                        actions: <Widget>[
                          FlatButton(
                              color: Colors.red,
                              textColor: Colors.white,
                              child: Text("NON"),
                              onPressed: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              }),
                          FlatButton(
                              color: Colors.green,
                              textColor: Colors.white,
                              child: Text("OUI"),
                              onPressed: () {
                                setState(() {
                                  record.reference.delete();
                                  Navigator.pop(context);
                                });
                              })
                        ],
                      );
                      }
                   );
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
                      content: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          Text("Nom de la tâche"),
                          TextField(
                            controller: TextEditingController()
                              ..text = record.name,
                            onChanged: (String value) {
                              record.reference.update({"name": value});
                            },
                          ),
                          Text("Date limite"),
                          DateTimeFormField(
                              initialValue: record.endDate != null ? DateTime.parse(record.endDate.toDate().toString()) : null,
                              onDateSelected: (DateTime date) {
                                setState(() {
                                  selectedDate = date;
                                  dateAsTimeStamp = Timestamp.fromDate(date);
                                  record.reference
                                      .update({"endDate": dateAsTimeStamp});
                                });
                              })
                        ],
                      ),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              setState(() {
                                record.name = input;
                                record.endDate = inputDate ;
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text("Modifier"))
                      ]);
                });
          },
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Etes-vous sûr de vouloir supprimer la tâche ?"),
                actions: <Widget>[
                  FlatButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      child: Text("NON"),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      }),
                  FlatButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      child: Text("OUI"),
                      onPressed: () {
                        setState(() {
                          record.reference.delete();
                          Navigator.pop(context);
                        });
                      })
                ],
              );
            }
        );
      },
    );
  }
}

class ListRecord {
  String name;
  String color;
  Timestamp dateFin;
  List<dynamic> tags = new List();
  final DocumentReference reference;

  ListRecord.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        name = map['name'],
        color = map['color'],
        dateFin = map['endDate'],
        tags = map['tags'];

  ListRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$color:$dateFin>";
}

class TodoRecord {
  String name;
  final bool checked;
  final DocumentReference reference;
  Timestamp endDate;

  TodoRecord.fromMap(Map<String, dynamic> map, {this.reference})

      : assert(map['name'] != null),
        assert(map['checked'] != null),
        name = map['name'],
        checked = map['checked'],
        endDate = map['endDate'];


  TodoRecord.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data(), reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$checked$endDate>";
}
