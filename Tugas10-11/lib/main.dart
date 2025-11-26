import 'package:flutter/material.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'session_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Future<Widget> _getHome() async {
    bool loggedIn = await SessionManager.isLoggedIn();
    return loggedIn ? const HomePage() : const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _getHome(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold( 
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data ?? const LoginPage();
          }
        },
      ),
    );
  }
}