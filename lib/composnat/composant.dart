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
      int quantite, String reference, String description, int ordre) async {
    final url = Uri.parse("http://192.168.43.194:8000/addC/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference": reference,
      "referenceA": widget.reference,
      "description": description,
      "ordre": ordre,
      "ordre": ordre,
    });

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);
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

  Future<bool> modification_quantite(
      int quantite, String reference, String mode) async {
    final url = Uri.parse("http://192.168.43.194:8000/updateQC/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference_c": reference,
      "mode": mode,
    });

    try {
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

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

  void _showEditQuantiteDialog(String reference, int quantiteActuelle) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: const Text('Modifier la quantité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Référence : $reference\nQuantité initiale : $quantiteActuelle',
                      style: GoogleFonts.dmSans(
                          fontSize: 15, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nouvelle valeur',
                  hintText: 'Entrer une quantité',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Choisissez l'action à appliquer :",
                style: GoogleFonts.dmSans(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Remplacer'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () async {
                      int? value = int.tryParse(controller.text);
                      if (value != null) {
                        bool? confirmed = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmation'),
                            content: Text(
                                'Voulez-vous vraiment remplacer la quantité du composant "$reference" par $value ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Confirmer'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await modification_quantite(value, reference, "set");
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Quantité remplacée par $value pour $reference"),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white),
                    label: const Text('Ajouter'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async {
                      int? value = int.tryParse(controller.text);
                      if (value != null) {
                        bool? confirmed = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmation'),
                            content: Text(
                                'Voulez-vous vraiment ajouter $value à la quantité du composant "$reference" ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Confirmer'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await modification_quantite(value, reference, "add");
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "$value ajoutée à la quantité de $reference"),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.remove_circle_outline,
                        color: Colors.white),
                    label: const Text('Retirer'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    onPressed: () async {
                      int? value = int.tryParse(controller.text);
                      if (value != null) {
                        bool? confirmed = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmation'),
                            content: Text(
                                'Voulez-vous vraiment retirer $value de la quantité du composant "$reference" ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Confirmer'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await modification_quantite(
                              value, reference, "remove");
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "$value retirée de la quantité de $reference"),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _quantiteControler = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    final TextEditingController _rControler = TextEditingController();
    final TextEditingController _ordreController = TextEditingController();
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
            color: hasLowStock ? Colors.red : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                color: Colors.blue,
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
              child: Icon(Icons.add, color: Colors.white),
            ),
            onPressed: () {
              _quantiteControler.clear();
              _descriptionController.clear();
              _rControler.clear();
              _ordreController.clear();
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
          ? Center(child: Text("Aucun composant"))
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
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataTextStyle: GoogleFonts.dmSans(),
                        headingTextStyle:
                            GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                        border: TableBorder.all(color: Colors.grey),
                        columns: const [
                          DataColumn(label: Text('Référence')),
                          DataColumn(label: Text('Description')),
                          DataColumn(label: Text('Quantité')),
                          DataColumn(label: Text('Ordre')),
                          DataColumn(label: Text('Supprimer')),
                        ],
                        rows: filteredComposant.map((composant) {
                          final int quantite = composant["quantite"];
                          final String reference = composant["reference"];
                          final bool isLowStock =
                              (int.tryParse(composant["quantite"].toString()) ??
                                      0) <
                                  100;
                          return DataRow(
                            color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (isLowStock) {
                                return Colors.red.withOpacity(0.2);
                              }
                              return null;
                            }),
                            cells: [
                              DataCell(Text(reference)),
                              DataCell(Text(composant["description"] ?? "")),
                              DataCell(
                                GestureDetector(
                                  onTap: () => _showEditQuantiteDialog(
                                      reference, quantite),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.blueAccent.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      quantite.toString(),
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(composant["ordre"].toString())),
                              DataCell(
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title:
                                            Text('Confirmation de suppression'),
                                        content: Text(
                                            'Voulez-vous vraiment supprimer ce composant ?'),
                                        actions: [
                                          TextButton(
                                            child: Text('Annuler'),
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                          ),
                                          TextButton(
                                            child: Text('Supprimer'),
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      bool success =
                                          await deleteComp(reference);
                                      if (!mounted) return;
                                      if (success) {
                                        await getComposant();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Composant supprimé avec succès !')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Erreur lors de la suppression.')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
