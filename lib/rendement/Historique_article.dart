import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Historique extends StatefulWidget {
  final String reference;
  const Historique({super.key, required this.reference});

  @override
  State<Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  List<dynamic>? articles_modifer;

  Future<bool> getArticlesModifier() async {
    final url = Uri.parse(
        "http://192.168.43.194:8000/getArticlesModifier/${widget.reference}/");
    final response =
        await http.post(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      setState(() {
        articles_modifer = json.decode(response.body)["articles_modifier"];
      });
      print("ahom houni");
      print(articles_modifer);

      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getArticlesModifier();
  }

  String formatDateTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(
        dateTimeStr); // Assurez-vous que c'est un format DateTime valide
    final DateFormat formatter = DateFormat(
        'yyyy-MM-dd HH:mm'); // Format avec année, mois, jour, heures et minutes
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Historique de ${widget.reference}",
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
      body: articles_modifer == null
          ? const Center(child: Text("Aucun article disponible"))
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          DataTable(
                            dataTextStyle: GoogleFonts.dmSans(),
                            headingTextStyle: GoogleFonts.dmSans(),
                            border: TableBorder.all(
                                color: Color(0xFFC0C0C0),
                                borderRadius: BorderRadius.circular(10)),
                            columnSpacing: 35,
                            columns: const [
                              DataColumn(label: Text('Référence')),
                              DataColumn(label: Text('Quantité')),
                              DataColumn(label: Text('date de modification')),
                            ],
                            rows: articles_modifer!.map((article) {
                              return DataRow(cells: [
                                DataCell(
                                    Text(article["article_id"].toString())),
                                DataCell(Text(
                                    article["nouvelle_quantite"].toString())),
                                DataCell(Text(
                                    formatDateTime(article["created_at"]))),
                              ]);
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
