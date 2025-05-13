import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AddArticle extends StatefulWidget {
  const AddArticle({super.key});

  @override
  State<AddArticle> createState() => _AddArticleState();
}

class _AddArticleState extends State<AddArticle> {
  TextEditingController _quantiteControler = TextEditingController();
  TextEditingController _rControler = TextEditingController();
  TextEditingController _dControler = TextEditingController();

  Stream<List<dynamic>> getArticlesStream() async* {
    final url = Uri.parse("http://192.168.43.194:8000/getArticles/");

    while (true) {
      // Boucle infinie pour écouter en continu
      await Future.delayed(
          Duration(seconds: 2)); // Vérifie toutes les 2 secondes

      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        yield json.decode(response.body)["articles"];
      } else {
        print("Erreur ${response.statusCode}");
        yield []; // Retourne une liste vide en cas d'erreur
      }
    }
  }

  Future<bool> AddArticle(
      int quantite, String reference, String description) async {
    final url = Uri.parse("http://192.168.43.194:8000/adda/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference": reference,
      "description": description
    });
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 201) {
      print("ajout terminé");
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Ajouter un article",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.71,
          ),
        ),
        iconTheme: IconThemeData(
          color:
              Colors.white, // Changer la couleur de l'icône (flèche de retour)
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _rControler,
                decoration: InputDecoration(
                  hintText: "reference",
                  hintStyle: GoogleFonts.dmSans(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                controller: _dControler,
                decoration: InputDecoration(
                  hintText: "decription",
                  hintStyle: GoogleFonts.dmSans(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextField(
                controller: _quantiteControler,
                decoration: InputDecoration(
                  hintText: "quantité",
                  hintStyle: GoogleFonts.dmSans(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  AddArticle(int.parse(_quantiteControler.text),
                      _rControler.text, _dControler.text);
                  Navigator.pop(context);
                },
                child: Container(
                    width: 400.28,
                    height: 43.74,
                    decoration: ShapeDecoration(
                      color: Color(0xFF1A1A27),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.47),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Ajouter l'article",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 14.58,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
