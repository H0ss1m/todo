import 'package:conditional_builder_rec/conditional_builder_rec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/modules/archive/archive.dart';
import 'package:todo/modules/complete/doneTasks.dart';
import 'package:todo/modules/newtask/newTask.dart';
import 'package:todo/shared/component/component.dart';
import 'package:todo/shared/component/constants.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';

// ignore: must_be_immutable
class Home extends StatelessWidget {
  List<Widget> screens = [
    Newtask(),
    Donetaskes(),
    Archive(),
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

  Home({super.key});

  void initState() {
    createDatabases();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {},
        builder: (BuildContext context, AppStates state) => Scaffold(
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
                      getDatabase(database).then((value) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        tasks = value;
                        isBottomSheetShown = !isBottomSheetShown;
                      });
                    });
                  }
                } else {
                  scaffoldKey.currentState
                      ?.showBottomSheet(
                        (context) => Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30)),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 25),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                textForm(
                                    text: "Task",
                                    errorMessage: "Task must not be empty",
                                    keyboardType: TextInputType.text,
                                    prefix: const Icon(Icons.title),
                                    controller: taskController,
                                    onTap: () {}),
                                const SizedBox(
                                  height: 15,
                                ),
                                textForm(
                                    text: "Time",
                                    errorMessage: "Time mustn't be empty",
                                    keyboardType: TextInputType.none,
                                    prefix:
                                        const Icon(Icons.watch_later_outlined),
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
                                    errorMessage: "Date mustn't be empty",
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
                      )
                      .closed
                      .then((value) {
                    isBottomSheetShown = !isBottomSheetShown;
                  });
                  isBottomSheetShown = !isBottomSheetShown;
                }
              },
              child: isBottomSheetShown
                  ? const Icon(Icons.add)
                  : const Icon(Icons.edit),
            ),
            bottomNavigationBar: BottomNavigationBar(
                showSelectedLabels: true,
                currentIndex: currentState,
                onTap: (value) {
                  currentState = value;
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu), label: "New Task"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.check_circle_outline),
                      label: "Done Taskes"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.archive_outlined), label: "Archive"),
                ]),
            body: ConditionalBuilderRec(
              condition: tasks.length > 0,
              builder: (context) => screens[currentState],
              fallback: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ),
    );
  }

  void createDatabases() async {
    var databasesPath = await getDatabasesPath();
    String path = "$databasesPath/todo.db";

    // حذف قاعدة البيانات القديمة - اختيارياً
    // await deleteDatabase(path);
    // print("Old database deleted");

    // إنشاء قاعدة البيانات
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print("Database created");
        await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY, 
          title TEXT, 
          date TEXT, 
          time TEXT, 
          status TEXT
        )
      ''').then((value) {
          print("Table created successfully");
        }).catchError((error) {
          print("Error creating table: ${error.toString()}");
        });
      },
      onOpen: (db) {
        getDatabase(db).then((value) {
          tasks = value;
        });
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

  Future<List<Map>> getDatabase(database) async {
    return await database!.rawQuery('SELECT * FROM tasks');
  }
}
