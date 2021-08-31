import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_flutter_assignment/todo_model.dart';

const String todoBoxName = "todo";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>(todoBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.amber,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

enum TodoFilter { ALL, COMPLETED, INCOMPLETED }

class _HomePageState extends State<HomePage> {
  late Box<TodoModel> todoBox;
  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController desController = TextEditingController();
  TodoFilter filters = TodoFilter.ALL;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoBox = Hive.box<TodoModel>(todoBoxName);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(onSelected: (value) {
            if (value == "All") {
              setState(() {
                filters = TodoFilter.ALL;
              });
            } else if (value == "Completed") {
              setState(() {
                filters = TodoFilter.COMPLETED;
              });
            } else {
              setState(() {
                filters = TodoFilter.INCOMPLETED;
              });
            }
            print(value);
          }, itemBuilder: (context) {
            return ["All", "Completed", "InCompeleted"].map((option) {
              return PopupMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList();
          })
        ],
      ),
      // body: Column(
      //   children: [
      //     ValueListenableBuilder(
      //       valueListenable: todoBox.listenable(),
      //       builder: (context, Box<TodoModel> todos, _) {
      //         List<int> keys = todos.keys.cast<int>().toList();

      //         return ListView.separated(
      //           itemBuilder: (_, index) {
      //             final TodoModel? todo = todos.get(keys[index]);
      //             return ListTile(
      //               title: Text(todo!.title),
      //               subtitle: Text(todo.Description),
      //               leading: Text("${keys[index]}"),
      //             );
      //           },
      //           separatorBuilder: (context, index) {
      //             return Divider();
      //           },
      //           itemCount: keys.length,
      //           shrinkWrap: true,
      //         );
      //       },
      //     )
      //   ],
      // ),
      body: Column(
        children: [
          ValueListenableBuilder(
              valueListenable: todoBox.listenable(),
              builder: (context, Box<TodoModel> todos, _) {
                final List<int> keys;
                if (filters == TodoFilter.ALL) {
                  keys = todos.keys.cast<int>().toList();
                } else if (filters == TodoFilter.COMPLETED) {
                  keys = todos.keys
                      .cast<int>()
                      .where((key) => todos.get(key)!.isCompleted)
                      .toList();
                } else {
                  keys = todos.keys
                      .cast<int>()
                      .where((key) => !todos.get(key)!.isCompleted)
                      .toList();
                }

                return ListView.separated(
                  itemBuilder: (context, index) {
                    final key = keys[index];
                    final TodoModel? todo = todos.get(key);
                    return ListTile(
                      title: Text(todo!.title),
                      leading: Text("${key}"),
                      subtitle: Text(todo.Description),
                      trailing: todo.isCompleted
                          ? Icon(
                              Icons.check_box,
                              color: Colors.green,
                            )
                          : null,
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          TodoModel mTodo = TodoModel(
                                              title: todo.title,
                                              Description: todo.Description,
                                              isCompleted: true);
                                          todoBox.put(key, mTodo);
                                          Navigator.pop(context);
                                        },
                                        child: Center(
                                          child: Text("Mark As Completed"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      onLongPress: () {
                        todoBox.delete(key);
                      },
                    );
                  },
                  separatorBuilder: (context, _) {
                    return Center(
                      child: Divider(
                        thickness: 2,
                        endIndent: width * 0.1,
                        indent: width * 0.1,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                  itemCount: keys.length,
                  shrinkWrap: true,
                );
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Title",
                            ),
                            controller: titleController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Must Have Title";
                              } else {
                                return null;
                              }
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            decoration:
                                InputDecoration(labelText: "Description"),
                            controller: desController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Must Have Description";
                              } else {
                                return null;
                              }
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final String title = titleController.text;
                                final String des = desController.text;
                                TodoModel todo = TodoModel(
                                    title: title,
                                    Description: des,
                                    isCompleted: false);
                                todoBox.add(todo);
                                Navigator.pop(context);
                              } else {
                                return;
                              }
                            },
                            child: Center(
                              child: Text("Add To-Do"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        },
        child: Icon(
          Icons.add,
        ),
      ),
    );
  }
}
