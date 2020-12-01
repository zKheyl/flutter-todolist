import 'package:flutter/material.dart';

void main() {
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
        accentColor: Colors.orange,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todos.add("test");
    todos.add("test2");
    todos.add("test3");
    todos.add("test4");
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Mes todos"),
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
                  trailing: IconButton
                    (icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ), 
                      onPressed: () {
                      setState(() {
                        todos.removeAt(index);
                      });
                    },
                  ),
                ),
              ),
                onDismissed: (direction) {
                  if(direction == DismissDirection.startToEnd){
                    todos.removeAt(index);
                  }
                },
              );
            }),
      );
  }
}
