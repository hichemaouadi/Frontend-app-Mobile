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
  List<dynamic> articles = [];
  List<dynamic> filteredArticles = [];
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<List<dynamic>> _articlesSubscription;
  bool _isLoading = true;
  final String _baseUrl = "http://192.168.43.194:8000";

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_filterArticles);
  }

  Future<void> _initializeData() async {
    await _loadArticles();
    _setupArticlesStream();
  }

  Future<void> _loadArticles() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/getArticles/"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          articles = data["articles"] ?? [];
          filteredArticles = List.from(articles);
        });
      } else {
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setupArticlesStream() {
    _articlesSubscription = Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => _fetchArticles())
        .listen((newArticles) {
      if (mounted) {
        setState(() {
          articles = newArticles;
          filteredArticles = List.from(articles);
        });
      }
    }, onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de stream: $error')),
      );
    });
  }

  Future<List<dynamic>> _fetchArticles() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/getArticles/"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body)["articles"] ?? [];
      } else {
        throw Exception("Erreur ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur de récupération: $e");
      return [];
    }
  }

  Future<void> _refreshArticles() async {
    await _loadArticles();
  }

  Future<bool> _modifyQuantity(int quantity, String reference) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/updateQ/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "quantite": quantity,
          "reference_article": reference,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quantité mise à jour avec succès')),
        );
        return true;
      }
      throw Exception("Erreur ${response.statusCode}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de mise à jour: $e')),
      );
      return false;
    }
  }

  Future<bool> _deleteArticle(String reference) async {
    try {
      final response = await http.delete(
        Uri.parse("$_baseUrl/deleteAricle/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"reference": reference}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article supprimé avec succès')),
        );
        return true;
      }
      throw Exception("Erreur ${response.statusCode}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de suppression: $e')),
      );
      return false;
    }
  }

  void _filterArticles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredArticles = articles.where((article) {
        return article["reference"].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _articlesSubscription.cancel();
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
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshArticles,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredArticles.isEmpty
                ? const Center(child: Text("Aucun article disponible"))
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
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              dataTextStyle: GoogleFonts.dmSans(),
                              headingTextStyle: GoogleFonts.dmSans(),
                              border: TableBorder.all(
                                color: const Color(0xFFC0C0C0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              columns: const [
                                DataColumn(label: Text('Référence')),
                                DataColumn(label: Text('Description')),
                                DataColumn(label: Text('Quantité')),
                                DataColumn(label: Text('Valider')),
                                DataColumn(label: Text('Supprimer')),
                              ],
                              rows: filteredArticles.map((article) {
                                final quantityController =
                                    TextEditingController(
                                  text: article["quantite"].toString(),
                                );

                                return DataRow(
                                  key: ValueKey(article["reference"]),
                                  cells: [
                                    DataCell(
                                      InkWell(
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Composant(
                                              reference: article["reference"],
                                            ),
                                          ),
                                        ),
                                        child: Text(article["reference"]),
                                      ),
                                    ),
                                    DataCell(Text(article["description"])),
                                    DataCell(
                                      SizedBox(
                                        width: 60,
                                        child: TextField(
                                          controller: quantityController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.green),
                                        onPressed: () => _modifyQuantity(
                                          int.tryParse(
                                                  quantityController.text) ??
                                              0,
                                          article["reference"],
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _showDeleteDialog(
                                            article["reference"]),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Future<void> _showDeleteDialog(String reference) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer cet article ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteArticle(reference);
              await _refreshArticles();
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
