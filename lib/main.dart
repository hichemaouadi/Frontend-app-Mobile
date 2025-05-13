import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sofima/Auth/login.dart';
import 'package:sofima/widgtes/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final FlutterSecureStorage storage = FlutterSecureStorage();

  Future<bool> verifToken() async {
    String? storedToken = await storage.read(key: 'token');
    if (storedToken == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: verifToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || snapshot.data == false) {
            return Login(); // Affiche la page de connexion si pas de token
          } else {
            return Welcome(); // Affiche la page d'accueil si token présent
          }
        },
      ),
    );
  }
}
