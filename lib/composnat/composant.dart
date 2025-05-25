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
  List<dynamic> composants = [];
  List<dynamic> filteredComposant = [];

  bool hasLowStock = false;

  final TextEditingController _searchController = TextEditingController();

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

  Future<bool> getComposant() async {
    final url = Uri.parse("http://192.168.43.194:8000/getComposant/");
    final body = jsonEncode({"reference": widget.reference});
    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          composants = data["composants"] ?? [];
          filteredComposant = List.from(composants);
          hasLowStock = composants.any((c) {
            final q = int.tryParse(c["quantite"].toString()) ?? 0;
            return q < 100;
          });
        });
        return true;
      } else {
        print("Erreur serveur: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Erreur getComposant: $e");
      return false;
    }
  }

  Future<bool> AddComposant(
      int quantite, String reference, String description, int ordre) async {
    final url = Uri.parse("http://192.168.43.194:8000/addC/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference": reference,
      "referenceA": widget.reference,
      "description": description,
      "ordre": ordre,
    });

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (response.statusCode == 201) {
        setState(() {
          final newComposant = {
            "quantite": quantite,
            "reference": reference,
            "description": description,
            "ordre": ordre,
          };
          composants.add(newComposant);
          filteredComposant = List.from(composants);
          hasLowStock = composants.any((c) {
            final q = int.tryParse(c["quantite"].toString()) ?? 0;
            return q < 100;
          });
        });

        // Ajout du message de confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Composant ajouté avec succès!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        return true;
      } else {
        print("Erreur ajout: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Erreur AddComposant: $e");
      return false;
    }
  }

  Future<bool> modification_quantite(int quantite, String reference) async {
    final url = Uri.parse("http://192.168.43.194:8000/updateQC/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference_c": reference,
    });

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (response.statusCode == 200) {
        await getComposant();
        return true;
      } else {
        print("Erreur update: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Erreur modification_quantite: $e");
      return false;
    }
  }

  Future<bool> deleteComp(String reference) async {
    final url = Uri.parse("http://192.168.43.194:8000/deleteComp/");
    final body = jsonEncode({"reference": reference});

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        setState(() {
          composants.removeWhere((c) => c["reference"] == reference);
          filteredComposant.removeWhere((c) => c["reference"] == reference);
          hasLowStock = composants.any((c) {
            final q = int.tryParse(c["quantite"].toString()) ?? 0;
            return q < 100;
          });
        });
        return true;
      } else {
        print("Erreur suppression: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Erreur deleteComp: $e");
      return false;
    }
  }

  void _filterComposants() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredComposant = composants.where((composant) {
        final ref = (composant["reference"] ?? "").toString().toLowerCase();
        return ref.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _quantiteControler = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    final TextEditingController _rControler = TextEditingController();
    final TextEditingController _ordreController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Composants de ${widget.reference}",
          style: GoogleFonts.dmSans(
            color: hasLowStock ? Colors.red : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
            onPressed: () {
              _quantiteControler.clear();
              _descriptionController.clear();
              _rControler.clear();
              _ordreController.clear();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _rControler,
                            decoration: InputDecoration(
                              hintText: "Référence",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _quantiteControler,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Quantité",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              hintText: "Description",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: _ordreController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Ordre",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          if (_rControler.text.isEmpty ||
                              _quantiteControler.text.isEmpty ||
                              _ordreController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Veuillez remplir tous les champs obligatoires."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          int? quantite =
                              int.tryParse(_quantiteControler.text.trim());
                          int? ordre =
                              int.tryParse(_ordreController.text.trim());
                          if (quantite == null || ordre == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Quantité et Ordre doivent être des nombres valides."),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          bool success = await AddComposant(
                            quantite,
                            _rControler.text.trim(),
                            _descriptionController.text.trim(),
                            ordre,
                          );
                          Navigator.pop(context);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Composant ajouté avec succès !"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Erreur lors de l'ajout."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text("Ajouter composant"),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: composants.isEmpty
          ? Center(child: Text("Aucun article"))
          : Column(
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
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataTextStyle: GoogleFonts.dmSans(),
                      headingTextStyle:
                          GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                      border: TableBorder.all(color: Colors.grey),
                      columns: const [
                        DataColumn(label: Text('Ordre')),
                        DataColumn(label: Text('Référence')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Quantité')),
                        DataColumn(label: Text('Valider')),
                        DataColumn(label: Text('Supprimer')),
                      ],
                      rows: filteredComposant.map((composant) {
                        final TextEditingController _quantiteControler =
                            TextEditingController(
                                text: composant["quantite"].toString());

                        final bool isLowStock =
                            (int.tryParse(composant["quantite"].toString()) ??
                                    0) <
                                100;

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (isLowStock) {
                              return Colors.red.withOpacity(0.3);
                            }
                            return null;
                          }),
                          cells: [
                            DataCell(
                              Text(composant["ordre"]?.toString() ?? ""),
                            ),
                            DataCell(Text(composant["reference"] ?? "")),
                            DataCell(Text(composant["description"] ??
                                "aucune description")),
                            DataCell(
                              TextField(
                                controller: TextEditingController(
                                    text: composant["quantite"]?.toString() ??
                                        "0"),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {},
                              ),
                            ),
                            DataCell(IconButton(
                              onPressed: () async {
                                final quantiteStr =
                                    (composant["quantite"]?.toString() ?? "0");
                                final quantite = int.tryParse(quantiteStr) ?? 0;
                                final reference = composant["reference"] ?? "";

                                if (reference.isEmpty) return;

                                bool success = await modification_quantite(
                                    quantite, reference);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Quantité enregistrée avec succès"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Erreur de mise à jour"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                                await getComposant();
                              },
                              icon: Icon(Icons.check_circle,
                                  color: Colors.green, size: 30),
                            )),
                            DataCell(IconButton(
                              onPressed: () async {
                                bool confirm = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Confirmation"),
                                    content: Text(
                                        "Voulez-vous vraiment supprimer ce composant ?"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text("Annuler")),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text("Supprimer")),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  bool success = await deleteComp(
                                      composant["reference"] ?? "");
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Composant supprimé"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Erreur lors de la suppression"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Icon(Icons.delete,
                                  color: Colors.red, size: 30),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
