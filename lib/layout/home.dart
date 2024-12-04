import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/modules/archive/archive.dart';
import 'package:todo/modules/complete/doneTasks.dart';
import 'package:todo/modules/newtask/newTask.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> screens = [
    const Donetaskes(),
    const Newtask(),
    const Archive(),
  ];

  List<String> title = [
    "New Task",
    "Done Tasks",
    "Archive",
  ];

  int currentState = 1;
  late Database database;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title[currentState]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scaffoldKey.currentState?.showBottomSheet((context) => Container(
            width: double.infinity,
            height: 120,
            color: Colors.red,
          ));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true,
          currentIndex: currentState,
          onTap: (value) {
            setState(() {
              currentState = value;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: "New Task"),
            BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline), label: "Done Taskes"),
            BottomNavigationBarItem(
                icon: Icon(Icons.archive_outlined), label: "Archive"),
          ]),
      body: screens[currentState],
    );
  }

  void createDatabases() async {
    database = await openDatabase(
      "todo.db",
      version: 1,
      onCreate: (database, version) async {
        print("Database created");
        await database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT,)')
            .then((value) {
          print("table created");
        }).catchError((error) {
          print("Error when creating table ${error.toString()}");
        });
      },
      onOpen: (database) {
        print("Database opened");
      },
    );
  }

  void insertDatabase() {
    database.transaction(
      (txn) async {
        txn
            .rawInsert(
                'INSERT INTO tasks(title, date, time, status) VALUES("first task", "46615", "646560", "new")')
            .then((value) {
          print("$value inserted successfully");
        }).catchError((error) {
          print("There was an error when inserting ${error.toString()}");
        });
      },
    );
  }
}
