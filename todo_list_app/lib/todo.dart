import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_list_app/dashboard.dart';

Map<String, dynamic> titleMap = new Map();
Map<String, dynamic> descriptionMap = new Map();

class AddListPage extends StatefulWidget {
  final getEditTitle;
  final getEditDes;
  final getVisibilityStatus;
  final getTitleID;
  final getDescriptionID;
  final desIDFromTitle;
  AddListPage({
    Key? key,
    required this.getEditTitle,
    required this.getEditDes,
    required this.getVisibilityStatus,
    required this.getTitleID,
    required this.getDescriptionID,
    required this.desIDFromTitle,
  }) : super(key: key);

  @override
  _AddListPageState createState() => _AddListPageState();
}

class _AddListPageState extends State<AddListPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  bool visible = true;

  String editTitle = "";
  String editDes = "";
  String snackBarStatus = "";
  String titleID = "";
  String desID = "";
  String fkDesID = "";

  @override
  void initState() {
    super.initState();
    editTitle = titleController.text = widget.getEditTitle;
    editDes = descriptionController.text = widget.getEditDes;
    visible = widget.getVisibilityStatus;
    titleID = widget.getTitleID;
    desID = widget.getDescriptionID;
    fkDesID = widget.desIDFromTitle;
  }

  snackBarShow(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  _editTask() {
    String dateTime = DateTime.now().toString();

    titleMap["title"] = titleController.text;
    titleMap["des_id"] = fkDesID;
    titleMap["date_time"] = dateTime;
    descriptionMap["description"] = descriptionController.text;

    cnToFB.update("title_db", titleID, titleMap);
    cnToFB.update("des_db", desID, descriptionMap);
    snackBarShow("Task Edited Successfully!");

    descriptionController.clear();
    titleController.clear();
    Navigator.pop(context);
  }

  _addTask() async {
    String id = "";

    String dateTime = DateTime.now().toString();

    descriptionMap["description"] = descriptionController.text;
    id = await cnToFB.push("des_db", descriptionMap);
    titleMap["title"] = titleController.text;
    titleMap["des_id"] = id;
    titleMap["task_status"] = "false";
    titleMap["date_time"] = dateTime;
    cnToFB.push("title_db", titleMap);
    snackBarShow("Task Added Successfully!");

    descriptionController.clear();
    titleController.clear();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo List App"),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("lib/assets/images/background.jpg"),
              fit: BoxFit.fill),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            titleTextField(),
            SizedBox(height: 10),
            descriptionTextField(),
            SizedBox(height: 10),
            buttons(),
          ],
        ),
      ),
    );
  }

  Widget titleTextField() {
    return Theme(
      data: Theme.of(context).copyWith(splashColor: Colors.transparent),
      child: TextFormField(
        controller: titleController,
        style: TextStyle(fontSize: 22.0, color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
          hintText: 'Enter Title',
          labelText: "Task Title",
          contentPadding:
              const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.secondary),
            borderRadius: BorderRadius.circular(10),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.green),
          ),
        ),
      ),
    );
  }

  Widget descriptionTextField() {
    return Flexible(
      child: Container(
        child: TextFormField(
          controller: descriptionController,
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          style: TextStyle(fontSize: 22.0, color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.7),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color:
                      Theme.of(context).colorScheme.secondary), //Colors.green),
              borderRadius: BorderRadius.circular(10),
            ),
            labelText: 'Enter Task Description',
          ),
        ),
      ),
    );
  }

  Widget buttons() {
    return Center(
      child: Column(
        children: <Widget>[
          Visibility(
            visible: visible,
            child: SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    _addTask();
                  } else {
                    showWarnigDialog(context,
                        "The text field should not be empty. Please fill in before adding task!");
                  }
                },
                child: Text('Set Task'),
              ),
            ),
          ),
          Visibility(
            visible: !visible,
            child: SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    showAlertDialog(context);
                  } else {
                    showWarnigDialog(context,
                        "The text field should not be empty. Please fill in before adding task!");
                  }
                },
                child: Text('Edit Task'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 100,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
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
        "Yes",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
      onPressed: () {
        _editTask();
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("WARNING: This task will be edited"),
      content: Text("Are you sure you want to edit this task?"),
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

  showWarnigDialog(BuildContext context, String note) {
    Widget continueButton = TextButton(
      child: Text(
        "ok",
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("NOTE: Something went wrong!"),
      content: Text(note),
      actions: [
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
