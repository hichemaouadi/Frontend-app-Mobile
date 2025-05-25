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
      return true;
    } else {
      print("Erreur ${response.statusCode}");
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    getArticlesModifier();
  }

  String formatDateTime(String dateTimeStr) {
    DateTime dateTime = DateTime.parse(dateTimeStr);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  String getActionLabel(String? mode) {
    if (mode == "add") return "Ajout";
    if (mode == "remove") return "Retrait";
    return "Remplacement";
  }

  List<DataRow> buildRows(List<dynamic> data) {
    return data.map((article) {
      String action = getActionLabel(article["mode"]);
      int ancienne = article["ancienne_quantite"] ?? 0;
      int nouvelle = article["nouvelle_quantite"] ?? 0;
      int qteChange;
      if (article["mode"] == "add") {
        qteChange = nouvelle - ancienne;
      } else if (article["mode"] == "remove") {
        qteChange = ancienne - nouvelle;
      } else {
        qteChange = nouvelle; // pour remplacement
      }
      return DataRow(cells: [
        DataCell(Text(article["article_id"].toString())),
        DataCell(Text(action)),
        DataCell(Text(ancienne.toString())),
        DataCell(Text(nouvelle.toString())),
        DataCell(Text(qteChange.toString())),
        DataCell(Text(formatDateTime(article["created_at"]))),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Regrouper les modifications par date
    List<dynamic> todayList = [];
    List<dynamic> yesterdayList = [];
    List<dynamic> otherList = [];

    if (articles_modifer != null) {
      DateTime now = DateTime.now();
      String today = DateFormat('yyyy-MM-dd').format(now);
      String yesterday = DateFormat('yyyy-MM-dd')
          .format(now.subtract(const Duration(days: 1)));
      for (var article in articles_modifer!) {
        String dateStr = article["created_at"];
        String dateOnly =
            DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr));
        if (dateOnly == today) {
          todayList.add(article);
        } else if (dateOnly == yesterday) {
          yesterdayList.add(article);
        } else {
          otherList.add(article);
        }
      }
      // Trier chaque liste avec les plus récentes en haut
      todayList.sort((a, b) => DateTime.parse(b["created_at"])
          .compareTo(DateTime.parse(a["created_at"])));
      yesterdayList.sort((a, b) => DateTime.parse(b["created_at"])
          .compareTo(DateTime.parse(a["created_at"])));
      otherList.sort((a, b) => DateTime.parse(b["created_at"])
          .compareTo(DateTime.parse(a["created_at"])));
    }

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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: articles_modifer == null
          ? const Center(child: Text("Aucun historique disponible"))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (todayList.isNotEmpty) ...[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12.0, top: 20, bottom: 8),
                      child: Text(
                        "Modifications d'aujourd'hui",
                        style: GoogleFonts.dmSans(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataTextStyle: GoogleFonts.dmSans(),
                        headingTextStyle:
                            GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                        border: TableBorder.all(
                          color: const Color(0xFFC0C0C0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        columnSpacing: 28,
                        columns: const [
                          DataColumn(label: Text('Référence')),
                          DataColumn(label: Text('Action')),
                          DataColumn(label: Text('Ancienne')),
                          DataColumn(label: Text('Nouvelle')),
                          DataColumn(label: Text('Qté changée')),
                          DataColumn(label: Text('Date')),
                        ],
                        rows: buildRows(todayList),
                      ),
                    ),
                  ],
                  if (yesterdayList.isNotEmpty) ...[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12.0, top: 25, bottom: 8),
                      child: Text(
                        "Modifications de hier",
                        style: GoogleFonts.dmSans(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataTextStyle: GoogleFonts.dmSans(),
                        headingTextStyle:
                            GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                        border: TableBorder.all(
                          color: const Color(0xFFC0C0C0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        columnSpacing: 28,
                        columns: const [
                          DataColumn(label: Text('Référence')),
                          DataColumn(label: Text('Action')),
                          DataColumn(label: Text('Ancienne')),
                          DataColumn(label: Text('Nouvelle')),
                          DataColumn(label: Text('Qté changée')),
                          DataColumn(label: Text('Date')),
                        ],
                        rows: buildRows(yesterdayList),
                      ),
                    ),
                  ],
                  if (otherList.isNotEmpty) ...[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 12.0, top: 25, bottom: 8),
                      child: Text(
                        "Modifications précédentes",
                        style: GoogleFonts.dmSans(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataTextStyle: GoogleFonts.dmSans(),
                        headingTextStyle:
                            GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                        border: TableBorder.all(
                          color: const Color(0xFFC0C0C0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        columnSpacing: 28,
                        columns: const [
                          DataColumn(label: Text('Référence')),
                          DataColumn(label: Text('Action')),
                          DataColumn(label: Text('Ancienne')),
                          DataColumn(label: Text('Nouvelle')),
                          DataColumn(label: Text('Qté changée')),
                          DataColumn(label: Text('Date')),
                        ],
                        rows: buildRows(otherList),
                      ),
                    ),
                  ],
                  if (todayList.isEmpty &&
                      yesterdayList.isEmpty &&
                      otherList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text("Aucune modification trouvée")),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
