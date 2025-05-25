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
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ordreController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Fonction pour ajouter un article (POST)
  Future<bool> addArticle(
      int quantite, String reference, String description, int ordre) async {
    final url = Uri.parse("http://192.168.43.194:8000/adda/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference": reference,
      "description": description,
      "ordre": ordre,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      print("Ajout terminé");
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  // Fonction appelée au clic du bouton
  void _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      final quantite = int.parse(_quantiteController.text.trim());
      final reference = _referenceController.text.trim();
      final description = _descriptionController.text.trim();
      final ordre = int.parse(_ordreController.text.trim());

      bool success = await addArticle(quantite, reference, description, ordre);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Article ajouté avec succès')),
        );

        _quantiteController.clear();
        _referenceController.clear();
        _descriptionController.clear();
        _ordreController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'article')),
        );
      }
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    hintText: "Référence",
                    hintStyle: GoogleFonts.dmSans(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Veuillez entrer une référence"
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: "Description",
                    hintStyle: GoogleFonts.dmSans(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Veuillez entrer une description"
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantiteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Quantité",
                    hintStyle: GoogleFonts.dmSans(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer une quantité";
                    }
                    if (int.tryParse(value) == null) {
                      return "La quantité doit être un nombre entier";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ordreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Ordre",
                    hintStyle: GoogleFonts.dmSans(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un ordre";
                    }
                    if (int.tryParse(value) == null) {
                      return "L'ordre doit être un nombre entier";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: _onSubmit,
                  child: Container(
                    width: 400,
                    height: 44,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1A1A27),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.5),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Ajouter l'article",
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
