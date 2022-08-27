import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery/login.dart';
// import 'package:grocery/sign_up.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LoginView(),
    // home: SignUpView(),
  ));
}
