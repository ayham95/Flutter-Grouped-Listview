import 'package:about_you/grouped_list_view.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  final contacts = <String>[
    'Adi Shamir',
    'Alan Kay',
    'Andrew Yao',
    'Barbara Liskov',
    'Kristen Nygaard',
    'Leonard Adleman',
    'Leslie Lamport',
    'Ole-Johan Dahl',
    'Peter Naur',
    'Robert E. Kahn',
    'Ronald L. Rivest',
    'Vinton G. Cerf',
  ];
  String query;
  String scrollToSection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            onChanged: (text) => setState(() {
              query = text;
            }),
          ),
          Expanded(
            child: GroupedListView(
              group: (item) => item[0],
              items: contacts,
              itemBuilder: (context, item, group) {
                return Card(
                  child: Text(item),
                  margin: EdgeInsets.all(4),
                );
              },
              groupHeaderBuilder: (context, val) {
                return Container(
                  padding: EdgeInsets.all(8),
                  child: Text(val, style: TextStyle(fontSize: 18),),
                  color: Colors.grey[200],
                );
              },
              scrollToSection: scrollToSection,
              search: query,
              searchableTerm: (item) => item,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        setState(() {
          scrollToSection = 'H';
        });
      }),
    );
  }
}

class Model {
  final String name;
  final int age;

  Model(this.name, this.age);

  @override
  String toString() {
    return '$name $age';
  }
}
