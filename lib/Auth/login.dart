import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sofima/widgtes/welcome.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("http://192.168.43.194:8000/login/");
    final requete = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': email,
        'password': password,
      }),
    );
    if (requete.statusCode == 200) {
      bool superadmin = json.decode(requete.body)["superAdmin"];
      storage.write(key: "token", value: json.decode(requete.body)["token"]);
      storage.write(
          key: "admin", value: json.decode(requete.body)["admin"].toString());
      storage.write(
          key: "superadmin",
          value: json.decode(requete.body)["superAdmin"].toString());
      storage.write(
          key: "utilisateur",
          value: json.decode(requete.body)["utilisateur"].toString());

      storage.write(
          key: "username", value: json.decode(requete.body)["username"]);

      bool admin = json.decode(requete.body)["admin"];
      bool utilisateur = json.decode(requete.body)["utilisateur"];
      print("superadmin = $superadmin , admin = $admin , user = $utilisateur");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Welcome()),
      );
      return true;
    } else {
      print("${requete.statusCode}");
      return false;
    }
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.all(30),
        children: [
          SizedBox(
            height: 221,
          ),
          Image.asset(
            "assets/images.png",
            height: 100,
            width: 100,
          ),
          SizedBox(
            height: 100,
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 6.96,
                left: 13.92,
                right: 6.96,
                bottom: 6.96,
              ),
              labelText: "Email",
              hintText: "Entrez votre email",
              labelStyle: GoogleFonts.dmSans(
                color: Color(0xFF1A1A27),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.24,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.22),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.22),
                borderSide: BorderSide(
                  color: Color(0xFF1A1A27), // Changer la couleur si nécessaire
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.22),
                borderSide: BorderSide(
                  color: Color(0xFF1A1A27), // Changer la couleur si nécessaire
                  width: 1,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _passwordController,
            obscureText: true, // Pour masquer le texte du mot de passe
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                top: 6.96,
                left: 13.92,
                right: 6.96,
                bottom: 6.96,
              ),
              labelText: "Mot de passe",
              hintText: "Entrez votre mot de passe",
              labelStyle: GoogleFonts.dmSans(
                color: Color(0xFF1A1A27),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.24,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.22),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.22),
                borderSide: BorderSide(
                  color: Color(0xFF1A1A27),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.22),
                borderSide: BorderSide(
                  color: Color(0xFF1A1A27),
                  width: 1,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 70,
          ),
          InkWell(
            onTap: () {
              signIn(
                  email: _emailController.text,
                  password: _passwordController.text);
            },
            child: Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Color(0xFF1A1A27),
              ),
              child: Center(
                  child: Text("login",
                      style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 14.58,
                          fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }
}
