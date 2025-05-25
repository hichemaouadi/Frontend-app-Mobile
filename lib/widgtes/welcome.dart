import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sofima/Auth/login.dart';
import 'package:sofima/articles/articles.dart';
import 'package:sofima/add/addarticle.dart';
import 'package:sofima/admin/admin.dart';
import 'package:sofima/rendement/rendement.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String userType = "";

  int articlesCount = 0;
  int composantsCount = 0;
  int composantsLowStock = 0;
  int articlesLowStock = 0;
  int articlesModifiedToday = 0;

  bool isLoading = true;
  String errorMsg = "";

  @override
  void initState() {
    super.initState();
    veriftypeUser();
    fetchStats();
  }

  Future<void> veriftypeUser() async {
    String? admin = await storage.read(key: "admin");
    String? superadmin = await storage.read(key: "superadmin");
    String? utilisateur = await storage.read(key: "utilisateur");

    if (admin == "true") {
      setState(() {
        userType = "admin";
      });
    } else if (superadmin == "true") {
      setState(() {
        userType = "superadmin";
      });
    } else if (utilisateur == "true") {
      setState(() {
        userType = "utilisateur";
      });
    } else {
      setState(() {
        userType = "";
      });
    }
  }

  /// Rafraîchit les stats et l'état
  Future<void> fetchStats() async {
    setState(() {
      isLoading = true;
      errorMsg = "";
    });
    try {
      // 1. Récupérer les articles
      final articlesRes =
          await http.get(Uri.parse('http://192.168.43.194:8000/getArticles/'));
      if (articlesRes.statusCode != 200) {
        throw Exception(
            "Erreur de récupération des articles (${articlesRes.statusCode})");
      }
      final articlesData = jsonDecode(utf8.decode(articlesRes.bodyBytes));
      final List<dynamic> articles = articlesData['articles'] ?? [];
      articlesCount = articles.length;
      articlesLowStock = articles.where((a) {
        int q = int.tryParse(a['quantite'].toString()) ?? 0;
        return q < 100;
      }).length;

      // 2. Récupérer tous les composants
      final composantsRes = await http
          .get(Uri.parse('http://192.168.43.194:8000/get_all_composant/'));
      if (composantsRes.statusCode != 200) {
        throw Exception(
            "Erreur de récupération des composants (${composantsRes.statusCode})");
      }
      final composantsData = jsonDecode(utf8.decode(composantsRes.bodyBytes));
      final List<dynamic> composants = composantsData['composants'] ?? [];
      composantsCount = composants.length;
      composantsLowStock = composants.where((c) {
        int q = int.tryParse(c['quantite'].toString()) ?? 0;
        return q < 100;
      }).length;

      // 3. Nombre de modifications d'articles aujourd'hui (pour chaque article)
      articlesModifiedToday = 0;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      for (var article in articles) {
        String ref = article["reference"].toString();
        final histRes = await http.post(
          Uri.parse('http://192.168.43.194:8000/get_articles_modifier/$ref/'),
          headers: {'Content-Type': 'application/json'},
        );
        if (histRes.statusCode == 200) {
          final histData = jsonDecode(utf8.decode(histRes.bodyBytes));
          final mods = histData['articles_modifier'] ?? [];
          articlesModifiedToday += (mods.where((m) {
            String dateStr = m['created_at'];
            String dateOnly =
                DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr));
            return dateOnly == today;
          }).length as int);
        }
      }

      setState(() {
        isLoading = false;
        errorMsg = "";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMsg = "Erreur lors du chargement des données : $e";
      });
    }
  }

  // Méthode pour rafraîchir la page (appeler fetchStats)
  Future<void> refreshPage() async {
    await fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Accueil",
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Rafraîchir",
            onPressed: isLoading ? null : refreshPage,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Articles'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
            ),
            if (userType == "admin" || userType == "superadmin")
              ListTile(
                leading: const Icon(Icons.assessment),
                title: const Text('Rendement'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Rendement()));
                },
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Ajouter un Article'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddArticle()));
              },
            ),
            if (userType == "admin" || userType == "superadmin")
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Actions'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Admin()));
                },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                String? username = await storage.read(key: "username");
                String? token = await storage.read(key: "token");
                if (username != null && token != null) {
                  await logoutUser(context, username, token);
                }
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg.isNotEmpty
              ? Center(
                  child: Text(
                    errorMsg,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: refreshPage,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        "Bienvenue !",
                        style: GoogleFonts.dmSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Statistiques actuelles",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Pie Chart Articles vs Composants
                      (articlesCount == 0 && composantsCount == 0)
                          ? const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                    "Aucune donnée à afficher pour les articles et composants."),
                              ),
                            )
                          : Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Text("Articles vs Composants",
                                        style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 180,
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            if (articlesCount > 0)
                                              PieChartSectionData(
                                                color: Colors.blue,
                                                value: articlesCount.toDouble(),
                                                title:
                                                    '$articlesCount Articles',
                                                radius: 50,
                                                titleStyle: GoogleFonts.dmSans(
                                                    color: Colors.white),
                                              ),
                                            if (composantsCount > 0)
                                              PieChartSectionData(
                                                color: Colors.green,
                                                value:
                                                    composantsCount.toDouble(),
                                                title:
                                                    '$composantsCount Composants',
                                                radius: 50,
                                                titleStyle: GoogleFonts.dmSans(
                                                    color: Colors.white),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(height: 18),

                      // Pie Chart Répartition Articles (stock normal/bas)
                      (articlesCount == 0)
                          ? const SizedBox()
                          : Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text("Répartition articles (donut)",
                                        style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 180,
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                          sections: [
                                            if ((articlesCount -
                                                    articlesLowStock) >
                                                0)
                                              PieChartSectionData(
                                                color: Colors.lightBlue,
                                                value: (articlesCount -
                                                        articlesLowStock)
                                                    .toDouble(),
                                                title: 'Normaux',
                                                radius: 50,
                                                titleStyle: GoogleFonts.dmSans(
                                                    color: Colors.white),
                                              ),
                                            if (articlesLowStock > 0)
                                              PieChartSectionData(
                                                color: Colors.orange,
                                                value:
                                                    articlesLowStock.toDouble(),
                                                title: 'Bas',
                                                radius: 50,
                                                titleStyle: GoogleFonts.dmSans(
                                                    color: Colors.white),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(height: 18),
                      // Line Chart modif articles aujourd'hui
                      (articlesModifiedToday == 0)
                          ? const SizedBox()
                          : Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text("Modifications d'articles aujourd'hui",
                                        style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 180,
                                      child: LineChart(
                                        LineChartData(
                                          titlesData: FlTitlesData(
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  final days = ['Aujourd\'hui'];
                                                  return Text(
                                                      days[value.toInt() % 1],
                                                      style: GoogleFonts.dmSans(
                                                          fontSize: 12));
                                                },
                                                interval: 1,
                                              ),
                                            ),
                                            leftTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: true),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                          ),
                                          lineBarsData: [
                                            LineChartBarData(
                                              isCurved: true,
                                              color: Colors.deepPurple,
                                              barWidth: 4,
                                              spots: [
                                                FlSpot(
                                                    0,
                                                    articlesModifiedToday
                                                        .toDouble()),
                                              ],
                                              dotData: FlDotData(show: true),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      const SizedBox(height: 18),
                      // Donut Chart composants (stock normal/bas)
                      (composantsCount == 0)
                          ? const SizedBox()
                          : Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text("Répartition composants (donut)",
                                        style: GoogleFonts.dmSans(
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 180,
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                          sections: [
                                            if ((composantsCount -
                                                    composantsLowStock) >
                                                0)
                                              PieChartSectionData(
                                                color: Colors.teal,
                                                value: (composantsCount -
                                                        composantsLowStock)
                                                    .toDouble(),
                                                title: 'Normaux',
                                                radius: 50,
                                                titleStyle: GoogleFonts.dmSans(
                                                    color: Colors.white),
                                              ),
                                            if (composantsLowStock > 0)
                                              PieChartSectionData(
                                                color: Colors.redAccent,
                                                value: composantsLowStock
                                                    .toDouble(),
                                                title: 'Bas',
                                                radius: 50,
                                                titleStyle: GoogleFonts.dmSans(
                                                    color: Colors.white),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
    );
  }

  Future<void> logoutUser(
      BuildContext context, String username, String token) async {
    final response = await http.post(
      Uri.parse('http://192.168.43.194:8000/logout/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "token": token,
      }),
    );

    if (response.statusCode == 200) {
      await storage.deleteAll();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } else {
      print("Erreur de déconnexion : ${response.body}");
    }
  }
}
