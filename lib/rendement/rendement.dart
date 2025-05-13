import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sofima/rendement/Historique_article.dart';
import 'package:sofima/rendement/historique_composant.dart';

class Rendement extends StatefulWidget {
  const Rendement({super.key});

  @override
  State<Rendement> createState() => _RendementState();
}

class _RendementState extends State<Rendement> {
  List<dynamic>? composants;
  List<dynamic>? articles;
  List<dynamic>? filteredComposants;
  List<dynamic>? filteredArticles;
  String searchQuery = "";

  FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> getComposant() async {
    final url = Uri.parse("http://192.168.43.194:8000/get_all_composant/");
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      setState(() {
        composants = json.decode(response.body)["composants"];
        filteredComposants = composants;
      });
    }
  }

  Future<void> getArticles() async {
    final url = Uri.parse("http://192.168.43.194:8000/getArticles/");
    final response =
        await http.get(url, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      setState(() {
        articles = json.decode(response.body)["articles"];
        filteredArticles = articles;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getArticles();
    getComposant();
  }

  void filterData(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredArticles = articles
          ?.where((article) =>
              article["reference"].toLowerCase().contains(searchQuery))
          .toList();
      filteredComposants = composants
          ?.where((composant) =>
              composant["reference"].toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double columnWidth = screenWidth * 0.4;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Rendement",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Rechercher par référence",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterData,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildDataTable(
                      "Articles", filteredArticles, columnWidth, true),
                  const SizedBox(height: 20),
                  buildDataTable(
                      "Composants", filteredComposants, columnWidth, false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDataTable(
      String title, List<dynamic>? data, double columnWidth, bool isArticle) {
    if (data == null || data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("Aucun $title trouvé"),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataTextStyle: GoogleFonts.dmSans(),
        headingTextStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
        border: TableBorder.all(
            color: const Color(0xFFC0C0C0),
            borderRadius: BorderRadius.circular(10)),
        columnSpacing: 20,
        columns: const [
          DataColumn(label: Text('Référence')),
          DataColumn(label: Text('Quantité')),
        ],
        rows: data.map((item) {
          return DataRow(cells: [
            DataCell(SizedBox(
              width: columnWidth,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => isArticle
                          ? Historique(reference: item["reference"])
                          : HistoriqueComposant(reference: item["reference"]),
                    ),
                  );
                },
                child: Text(item["reference"].toString()),
              ),
            )),
            DataCell(SizedBox(
              width: columnWidth,
              child: Text("${item["quantite"]}"),
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
