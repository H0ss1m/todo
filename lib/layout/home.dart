import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/modules/archive/archive.dart';
import 'package:todo/modules/complete/doneTasks.dart';
import 'package:todo/modules/newtask/newTask.dart';
import 'package:todo/shared/component/component.dart';

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
  Database? database;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  bool isBottomSheetShown = false;
  var taskController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  var statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    createDatabases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(title[currentState]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isBottomSheetShown) {
            if (formKey.currentState!.validate()) {
              insertDatabase(
                title: taskController.text,
                date: dateController.text,
                time: timeController.text,
              ).then((value) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                setState(() {
                  isBottomSheetShown = !isBottomSheetShown;
                });
              });
            }
          } else {
            scaffoldKey.currentState?.showBottomSheet(
              (context) => Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                  color: Colors.white,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      textForm(
                          text: "Task",
                          keyboardType: TextInputType.text,
                          prefix: const Icon(Icons.title),
                          controller: taskController,
                          onTap: () {}),
                      const SizedBox(
                        height: 15,
                      ),
                      textForm(
                          text: "Time",
                          keyboardType: TextInputType.none,
                          prefix: const Icon(Icons.watch_later_outlined),
                          controller: timeController,
                          onTap: () {
                            showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((value) {
                              // ignore: use_build_context_synchronously
                              timeController.text =
                                  // ignore: use_build_context_synchronously
                                  value!.format(context).toString();
                            });
                          }),
                      const SizedBox(
                        height: 15,
                      ),
                      textForm(
                          text: "Date",
                          keyboardType: TextInputType.none,
                          prefix: const Icon(Icons.calendar_month),
                          controller: dateController,
                          onTap: () {
                            showDatePicker(
                                    context: context,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2030),
                                    initialDate: DateTime.now())
                                .then((value) {
                              dateController.text =
                                  DateFormat.yMMMd().format(value!);
                            });
                          }),
                      // const SizedBox(
                      //   height: 15,
                      // ),
                      // textForm(
                      //     text: "Status",
                      //     keyboardType: TextInputType.text,
                      //     prefix: const Icon(Icons.flag_circle_outlined),
                      //     controller: statusController,
                      //     onTap: () {}),
                    ],
                  ),
                ),
              ),
              elevation: 50,
            );
            setState(() {
              isBottomSheetShown = !isBottomSheetShown;
            });
          }
        },
        child:
            isBottomSheetShown ? const Icon(Icons.add) : const Icon(Icons.edit),
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
        // ignore: avoid_print
        print("Database created");
        await database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          // ignore: avoid_print
          print("table created");
        }).catchError((error) {
          // ignore: avoid_print
          print("Error when creating table ${error.toString()}");
        });
      },
      onOpen: (database) {
        // ignore: avoid_print
        print("Database opened");
      },
    );
  }

  Future insertDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
    return await database?.transaction(
      (txn) {
        return txn
            .rawInsert(
                'INSERT INTO tasks (title, date, time, status) VALUES("$title", "$date", "$time", "new")')
            .then((value) {
          // ignore: avoid_print
          print("$value inserted successfully");
        }).catchError((error) {
          // ignore: avoid_print
          print("There was an error while inserting ${error.toString()}");
        });
      },
    );
  }
}
