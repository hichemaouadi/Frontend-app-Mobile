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
  final TextEditingController _searchController = TextEditingController();

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

  Future<bool> modification_quantite(int quantite, String reference) async {
    final url = Uri.parse("http://192.168.43.194:8000/updateQ/");
    final body = jsonEncode({
      "quantite": quantite,
      "reference_article": reference,
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

  Future<void> _showModifyConfirmDialog(int quantite, String reference) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content:
            Text('Voulez-vous vraiment modifier la quantité à $quantite ?'),
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

    if (confirm == true) {
      bool success = await modification_quantite(quantite, reference);
      if (!mounted) return;

      if (success) {
        await getArticles();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantité modifiée avec succès !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la modification.')),
        );
      }
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
    setState(() {
      filteredArticles = articles?.where((article) {
        return article["reference"].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
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
            fontSize: 14,
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
                                DataColumn(label: Text('Référence')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Ordre')),
                                DataColumn(label: Text('Quantité')),
                                DataColumn(label: Text('Valider')),
                                DataColumn(label: Text('Supprimer')),
                              ],
                              rows: filteredArticles!.map((article) {
                                TextEditingController _quantiteController =
                                    TextEditingController(
                                        text: article["quantite"].toString());

                                int quantite = article["quantite"];

                                return DataRow(
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
                                                  reference:
                                                      article["reference"]),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          article["reference"].toString(),
                                          style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(
                                        article["description"].toString())),
                                    DataCell(Text(article["ordre"].toString())),
                                    DataCell(
                                      SizedBox(
                                        width: 120,
                                        child: TextField(
                                          controller: _quantiteController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 80,
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () {
                                              int newQty = int.tryParse(
                                                      _quantiteController
                                                          .text) ??
                                                  article["quantite"];
                                              _showModifyConfirmDialog(
                                                  newQty, article["reference"]);
                                            },
                                            icon: const Icon(
                                              Icons.check_circle_sharp,
                                              color: Colors.green,
                                              size: 30,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: 80,
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Confirmation'),
                                                  content: Text(
                                                      'Voulez-vous vraiment supprimer l\'article "${article["reference"]}" ?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child:
                                                          const Text('Annuler'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: const Text(
                                                          'Supprimer'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                bool deleted =
                                                    await delete_article(
                                                        article["reference"]);
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
    );
  }
}
