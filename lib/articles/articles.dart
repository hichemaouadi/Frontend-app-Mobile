import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sofima/composnat/composant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic>? articles;
  List<dynamic>? filteredArticles;
  String? username;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  List<dynamic>? articles;
  List<dynamic>? filteredArticles;
  String? username;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

  Future<bool> getArticles() async {
    final url = Uri.parse("http://192.168.43.194:8000/getArticles/");
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

  Future<bool> getArticles() async {
    final url = Uri.parse("http://192.168.43.194:8000/getArticles/");
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      if (!mounted) return false;
      setState(() {
        articles = json.decode(response.body)["articles"];
        filteredArticles = articles;
      });
      username = await storage.read(key: "username");
      await storage.read(key: "admin");
      await storage.read(key: "superadmin");
      await storage.read(key: "utilisateur");
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  Future<bool> modification_quantite(
      int quantite, String reference, String mode) async {
    final url = Uri.parse("http://192.168.43.194:8000/update_quantite/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference_article": reference,
      "mode": mode,
    });
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return response.statusCode == 200;
  }

  Future<bool> delete_article(String reference) async {
    final url = Uri.parse("http://192.168.43.194:8000/deleteAricle/");
    final body = jsonEncode({"reference": reference});
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    return response.statusCode == 200;
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
                                'Voulez-vous vraiment remplacer la quantité de l\'article "$reference" par $value ?'),
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
                          await _handleModifyQuantite(reference, value, "set");
                          Navigator.pop(context);
                          _showActionSnackBar(
                              "remplacée", value, quantiteActuelle, "set");
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
                                'Voulez-vous vraiment ajouter $value à la quantité de l\'article "$reference" ?'),
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
                          await _handleModifyQuantite(reference, value, "add");
                          Navigator.pop(context);
                          _showActionSnackBar(
                              "ajoutée", value, quantiteActuelle, "add");
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
                                'Voulez-vous vraiment retirer $value de la quantité de l\'article "$reference" ?'),
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
                          await _handleModifyQuantite(
                              reference, value, "remove");
                          Navigator.pop(context);
                          _showActionSnackBar(
                              "retirée", value, quantiteActuelle, "remove");
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

  void _showActionSnackBar(String action, int value, int initial, String mode) {
    String msg = "";
    switch (mode) {
      case "set":
        msg = "La quantité a été remplacée par $value (avant : $initial)";
        break;
      case "add":
        msg = "$value ajoutée à la quantité (avant : $initial)";
        break;
      case "remove":
        msg = "$value retirée de la quantité (avant : $initial)";
        break;
      default:
        msg = "Action effectuée";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _handleModifyQuantite(
      String reference, int quantite, String mode) async {
    bool success = await modification_quantite(quantite, reference, mode);
    if (!mounted) return;
    if (success) {
      await getArticles();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la modification.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getArticles();
    _searchController.addListener(_filterArticles);
  }

  void _filterArticles() {
    String query = _searchController.text.toLowerCase();
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredArticles = articles?.where((article) {
        return article["reference"].toLowerCase().contains(query);
      filteredArticles = articles?.where((article) {
        return article["reference"].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterArticles);
    _searchController.removeListener(_filterArticles);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Liste des Articles",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 1.71,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: (articles == null || filteredArticles == null)
          ? const Center(child: CircularProgressIndicator())
          : filteredArticles!.isEmpty
              ? const Center(child: Text("Aucun article trouvé."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Recherche par référence',
                            labelStyle: GoogleFonts.dmSans(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
      body: (articles == null || filteredArticles == null)
          ? const Center(child: CircularProgressIndicator())
          : filteredArticles!.isEmpty
              ? const Center(child: Text("Aucun article trouvé."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Recherche par référence',
                            labelStyle: GoogleFonts.dmSans(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
                              headingTextStyle: GoogleFonts.dmSans(),
                              border: TableBorder.all(
                                color: const Color(0xFFC0C0C0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              columnSpacing: 35,
                              columns: [
                              columnSpacing: 35,
                              columns: [
                                DataColumn(label: Text('Référence')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Ordre')),
                                DataColumn(label: Text('Ordre')),
                                DataColumn(label: Text('Quantité')),
                                DataColumn(label: Text('Supprimer')),
                              ],
                              rows: filteredArticles!.map((article) {
                                int quantite = article["quantite"];
                                String reference = article["reference"];
                                return DataRow(
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      return (quantite < 100)
                                          ? Colors.red.shade100
                                          : null;
                                    },
                                  ),
                                  color:
                                      MaterialStateProperty.resolveWith<Color?>(
                                    (Set<MaterialState> states) {
                                      return (quantite < 100)
                                          ? Colors.red.shade100
                                          : null;
                                    },
                                  ),
                                  cells: [
                                    DataCell(
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Composant(
                                                  reference: reference),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          reference,
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(
                                        article["description"].toString())),
                                    DataCell(Text(article["ordre"].toString())),
                                    DataCell(Text(
                                        article["description"].toString())),
                                    DataCell(Text(article["ordre"].toString())),
                                    DataCell(
                                      GestureDetector(
                                        onTap: () => _showEditQuantiteDialog(
                                            reference, quantite),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent
                                                .withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            quantite.toString(),
                                            style: const TextStyle(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Confirmation'),
                                              content: Text(
                                                  'Voulez-vous vraiment supprimer l\'article "$reference" ?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('Annuler'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child:
                                                      const Text('Supprimer'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            bool deleted =
                                                await delete_article(reference);
                                            if (deleted && mounted) {
                                              await getArticles();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Article supprimé avec succès !'),
                                                ),
                                              );
                                            } else if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Erreur lors de la suppression.'),
                                                ),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ),
    );
  }
}
