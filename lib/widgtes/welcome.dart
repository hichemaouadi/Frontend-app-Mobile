import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sofima/articles/articles.dart';
import 'package:sofima/add/addarticle.dart';
import 'package:sofima/admin/admin.dart';
import 'package:sofima/rendement/rendement.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sofima/Auth/login.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  String userType = "";

  // Vérifie le type d'utilisateur
  // Vérifie le type d'utilisateur
  Future<void> veriftypeUser() async {
    String? admin = await storage.read(key: "admin");
    String? superadmin = await storage.read(key: "superadmin");
    String? utilisateur = await storage.read(key: "utilisateur");

    if (admin == "true") {
      setState(() {
        userType = "admin";
      });
    } else if (superadmin == "true") {
      setState(() {
        userType = "superadmin";
      });
    } else if (utilisateur == "true") {
      setState(() {
        userType = "utilisateur";
      });
    } else {
      setState(() {
        userType = "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    veriftypeUser();
    veriftypeUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Accueil",
          "Accueil",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.71,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text('Articles'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            if (userType == "admin" || userType == "superadmin")
              ListTile(
                leading: Icon(Icons.assessment),
                title: Text('Rendement'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Rendement()));
                },
              ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Ajouter un Article'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddArticle()));
              },
            ),
            if (userType == "admin" || userType == "superadmin")
              ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Admin Actions'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Admin()));
                },
              ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Déconnexion'),
              onTap: () async {
                String? username = await storage.read(key: "username");
                String? token = await storage.read(key: "token");
                if (username != null && token != null) {
                  await logoutUser(context, username, token);
                }
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          "Bienvenue ! Choisissez une option dans le menu.",
          style: TextStyle(fontSize: 18),
        ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.black),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.article),
              title: Text('Articles'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            if (userType == "admin" || userType == "superadmin")
              ListTile(
                leading: Icon(Icons.assessment),
                title: Text('Rendement'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Rendement()));
                },
              ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Ajouter un Article'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddArticle()));
              },
            ),
            if (userType == "admin" || userType == "superadmin")
              ListTile(
                leading: Icon(Icons.admin_panel_settings),
                title: Text('Admin Actions'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Admin()));
                },
              ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Déconnexion'),
              onTap: () async {
                String? username = await storage.read(key: "username");
                String? token = await storage.read(key: "token");
                if (username != null && token != null) {
                  await logoutUser(context, username, token);
                }
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
          "Bienvenue ! Choisissez une option dans le menu.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<void> logoutUser(
      BuildContext context, String username, String token) async {
    final response = await http.post(
      Uri.parse('http://192.168.43.194:8000/logout/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "token": token,
      }),
    );

    if (response.statusCode == 200) {
      await storage.deleteAll();
      // Redirige en utilisant la classe directement
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } else {
      print("Erreur de déconnexion : ${response.body}");
    }
  }
}
