import 'dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyB7eXfRcBnl9n-mT7QqVRpfRo_gLGNQxA0",
      appId: "1:1023083278918:android:63bd8b9943bb44bb419047",
      messagingSenderId: "1023083278918",
      projectId: "todolist-5c6df",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Todo List App",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}
