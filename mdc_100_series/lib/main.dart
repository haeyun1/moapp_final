import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shrine/cart.dart';

import 'firebase_options.dart';
import 'home.dart';
import 'login.dart';
import 'add.dart';
import 'app_state.dart';
import 'profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      builder: ((context, child) => const ShrineApp()),
    ),
  );
}

class ShrineApp extends StatelessWidget {
  const ShrineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        '/profile': (BuildContext context) => const Profile(),
        '/addproduct': (BuildContext context) => const AddPage(),
        '/cart': (BuildContext context) => CartPage(),
        '/': (BuildContext context) => const HomePage(),
      },
      theme: ThemeData.light(useMaterial3: true),
    );
  }
}
