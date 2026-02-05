import 'package:dq_app/core/enums/db_tables_enums.dart';
import 'package:dq_app/core/manager/hive_manager.dart';
import 'package:dq_app/src/presentation/auth/login/login_page.dart';
import 'package:dq_app/src/presentation/dashBoard/bottomNavigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async{

    WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await HiveManager.init();
  runApp(const MyApp());  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    HiveManager.get(DbTable.auth, 'current');
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DQ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: getInitialPage(),
    );
  }

  Widget getInitialPage() {
  final auth = HiveManager.get(DbTable.auth, 'current');

  if (auth != null && auth['isLoggedIn'] == true) {
    return const Bottomnavigation(); 
  }

  return const LoginPage();
}

}




