import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/todo.dart';
import 'services/query.dart';
import 'dart:math';

final cnToFB = Hquery();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool checkBoxValue = false;

  void deleteData(String desID, String titleID) {
    cnToFB.deleteByID("des_db", desID);
    cnToFB.deleteByID("title_db", titleID);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task deleted!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List App"),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.info,
              color: Colors.white,
            ),
            onPressed: () {
              Widget okButton = TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );

              AlertDialog alert = AlertDialog(
                title: Text("About app"),
                content: Text(
                    "This application is made for listing task that the user want to finish. \n\n * The user can set title and description of the task. \n * The user can add, edit and delete task. \n * The user can mark status of the task if the task is already finished for review purposes. \n\n This app is made with: \n - Flutter framework v2.2.3 \n - Dart v2.13.4 \n\nVersion: 1.2 \n\n Developed by: Marben C.Villaflor \n Date released: February 16, 2022"),
                actions: [
                  okButton,
                ],
              );

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/assets/images/background.jpg"),
              fit: BoxFit.fill),
        ),
        child: nestedStreamBuilder(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddListPage(
                getEditTitle: "",
                getEditDes: "",
                desIDFromTitle: "",
                getVisibilityStatus: true,
                getTitleID: "",
                getDescriptionID: "",
              ),
            ),
          );
        },
        tooltip: 'Add To Do List',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget nestedStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
      stream: cnToFB.getSnapSorted("title_db", "date_time"),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Something went wrong"),
          );
        } else if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return StreamBuilder<QuerySnapshot>(
            stream: cnToFB.getSnap("des_db"),
            builder: (context2, snapshot2) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("Something went wrong"),
                );
              } else if (!snapshot2.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                List titleList = snapshot.data!.docs;
                List descriptionList = snapshot2.data!.docs;
                Map todoMap = new Map();
                List tasks = [];

                for (var titleItem in titleList) {
                  todoMap = {};
                  for (var desItem in descriptionList) {
                    if (titleItem["des_id"] == desItem.id) {
                      todoMap["title_data"] = titleItem["title"];
                      todoMap["fk_des_id_data"] = titleItem["des_id"];
                      todoMap["task_status"] = titleItem["task_status"];
                      todoMap["date_time"] = titleItem["date_time"];
                      todoMap["title_id"] = titleItem.id;
                      todoMap["description_id"] = desItem.id;
                      todoMap["description_data"] = desItem["description"];
                    }
                  }
                  tasks.add(todoMap);
                }
                return tasksList(tasks);
              }
            },
          );
        }
      },
    );
  }

  TextDecoration lineThrough(bool crash) {
    if (crash) {
      return TextDecoration.lineThrough;
    }
    return TextDecoration.none;
  }

  Widget tasksList(List tasks) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0),
            height: MediaQuery.of(context).size.height,
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  color: Colors
                      .primaries[Random().nextInt(Colors.primaries.length)]
                      .withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.black, width: 1),
                  ),
                  child: ListTile(
                    tileColor: Colors.transparent,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddListPage(
                            getEditTitle: tasks[index]["title_data"].toString(),
                            getEditDes:
                                tasks[index]["description_data"].toString(),
                            desIDFromTitle:
                                tasks[index]["fk_des_id_data"].toString(),
                            getTitleID: tasks[index]["title_id"].toString(),
                            getDescriptionID:
                                tasks[index]["description_id"].toString(),
                            getVisibilityStatus: false,
                          ),
                        ),
                      );
                    },
                    leading: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showAlertDialog(
                          context,
                          tasks[index]["description_id"].toString(),
                          tasks[index]["title_id"].toString(),
                        );
                      },
                    ),
                    title: Text(
                      tasks[index]["title_data"].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        decoration:
                            lineThrough(tasks[index]["task_status"] == "true"),
                      ),
                    ),
                    subtitle: Text(
                      tasks[index]["description_data"].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        decoration:
                            lineThrough(tasks[index]["task_status"] == "true"),
                      ),
                    ),
                    trailing: Checkbox(
                      value:
                          getBoolValue(tasks[index]["task_status"].toString()),
                      onChanged: (bool? value) {
                        showNoteDialog(context, value.toString(),
                            tasks[index]["title_id"]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  taskStatus(String status, String id) {
    Map<String, dynamic> checkBoxValue = new Map();
    checkBoxValue["task_status"] = status;
    cnToFB.update("title_db", id, checkBoxValue);
  }

  bool getBoolValue(String value) {
    bool val;
    if (value.toLowerCase() == "true") {
      val = true;
      return val;
    } else if (value.toLowerCase() == "false") {
      return false;
    }
    return false;
  }

  showAlertDialog(BuildContext context, String title, String description) {
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(
        "Delete",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
      onPressed: () {
        deleteData(title, description);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("WARNING: This task will be deleted"),
      content: Text("Are you sure you want to delete this task?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showNoteDialog(BuildContext context, String value, String id) {
    Widget cancelButton = TextButton(
      child: Text("No"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () {
        taskStatus(value, id);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("NOTE: Some changes of task status"),
      content: Text(
          "The task is checked if you are finish with this task and unchecked if it is not finished yet. Click \"Yes\" if you want to confirm some changes!"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
