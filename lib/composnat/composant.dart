import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Composant extends StatefulWidget {
  final String reference;
  const Composant({super.key, required this.reference});

  @override
  State<Composant> createState() => _ComposantState();
}

class _ComposantState extends State<Composant> {
  List<dynamic>? composants;
  List<dynamic>? filteredComposant; // Liste pour les articles filtrés

  Future<bool> getComposant() async {
    final url = Uri.parse("http://192.168.43.194:8000/getComposant/");
    final body = jsonEncode({"reference": widget.reference});
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      print("success");
      setState(() {
        composants = json.decode(response.body)["composants"];
        filteredComposant = composants;
      });
      print(composants);
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  Future<bool> AddComposant(
      int quantite, String reference, String description) async {
    final url = Uri.parse("http://192.168.43.194:8000/addC/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference": reference,
      "referenceA": widget.reference,
      "description": description,
    });

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 201) {
      print("Composant ajouté");

      // Ajout du composant à la liste sans quitter la page
      setState(() {
        // Crée un objet représentant le composant ajouté (assurez-vous que le format correspond à votre API)
        final newComposant = {
          "quantite": quantite,
          "reference": reference,
          "description": description,
        };

        // Ajouter le composant à la liste des composants et des composants filtrés
        composants?.add(newComposant);
        filteredComposant = composants; // Met à jour les composants filtrés
      });
      return true;
    } else {
      print("Erreur ${response.body}");
      return false;
    }
  }

  Future<bool> modification_quantite(int quantite, String reference) async {
    final url = Uri.parse("http://192.168.43.194:8000/updateQC/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference_c": reference,
    });
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: body);

    if (response.statusCode == 200) {
      print("modification terminé");
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  TextEditingController _searchController = TextEditingController();

  void _filterComposants() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredComposant = composants?.where((composant) {
        return composant["reference"].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<bool> deleteComp(String reference) async {
    final url = Uri.parse("http://192.168.43.194:8000/deleteComp/");
    final body = jsonEncode({"reference": reference});
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print("Suppression terminée");

      // Supprimer l'élément de la liste
      setState(() {
        composants
            ?.removeWhere((composant) => composant["reference"] == reference);
        filteredComposant
            ?.removeWhere((composant) => composant["reference"] == reference);
      });

      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getComposant();
    _searchController.addListener(_filterComposants);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterComposants);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _quantiteControler = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    TextEditingController _rControler = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Composants de ${widget.reference}",
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
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8), // Un peu d'espace autour de l'icône
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue, // Couleur du cercle
              ),
              child: Icon(Icons.add, color: Colors.white), // L'icône en blanc
            ), // Icône "+"
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text("Voulez-vous continuer ?"),
                    actions: [
                      TextField(
                        controller: _rControler,
                        decoration: InputDecoration(
                          hintText: "Référence",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _quantiteControler,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Quantité",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            AddComposant(int.parse(_quantiteControler.text),
                                _rControler.text, _descriptionController.text);
                            Navigator.pop(context);
                          },
                          child: Text("Ajouter composant"),
                        ),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: composants == null || composants == [] || composants == [{}]
          ? Center(
              child: Text(
                "No articles",
                style: TextStyle(color: Colors.black),
              ),
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Recherche par référence',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: DataTable(
                    dataTextStyle: GoogleFonts.dmSans(),
                    headingTextStyle: GoogleFonts.dmSans(),
                    border: TableBorder.all(
                      color: Color(0xFFC0C0C0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    columnSpacing: 35,
                    columns: [
                      const DataColumn(label: Text('Référence')),
                      const DataColumn(label: Text('Description')),
                      const DataColumn(label: Text('Quantité')),
                      const DataColumn(label: Text('valider')),
                      const DataColumn(label: Text('Supprimer')),
                    ],
                    rows: filteredComposant!.map((composant) {
                      TextEditingController _quantiteControler =
                          TextEditingController(
                        text: composant["quantite"].toString(),
                      );
                      return DataRow(cells: [
                        DataCell(Text(composant["reference"].toString())),
                        DataCell(Text(
                            composant["description"] ?? "aucun description")),
                        DataCell(TextField(
                          controller: _quantiteControler,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )),
                        DataCell(
                          SizedBox(
                            width: 80, // Ajuste cette valeur selon tes besoins
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min, // Évite l'expansion inutile
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    modification_quantite(
                                      int.parse(_quantiteControler.text),
                                      composant["reference"],
                                    );
                                  },
                                  icon: Center(
                                    child: Icon(
                                      Icons.check_circle_sharp,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 80, // Ajuste cette valeur selon tes besoins
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Supprimer'),
                                          content: Text(
                                              'Etes-vous sûr de vouloir supprimer cet composant ?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                deleteComp(
                                                    composant["reference"]);
                                                setState(() {});
                                                Navigator.pop(context);
                                                setState(() {});
                                              },
                                              child: Text('Confirmer'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.delete,
                                      color: Colors.red, size: 40),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
