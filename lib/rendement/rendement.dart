import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sofima/rendement/Historique_article.dart';
import 'package:sofima/rendement/historique_composant.dart';

class Modification {
  final String type;
  final String reference;
  final int quantite; // On la garde pour le modèle, mais on ne l'affiche pas

  Modification({
    required this.type,
    required this.reference,
    required this.quantite,
  });

  factory Modification.fromJson(Map<String, dynamic> json) {
    return Modification(
      type: json['type'],
      reference: json['reference'],
      quantite: json['quantite'],
    );
  }
}

class Rendement extends StatefulWidget {
  const Rendement({Key? key}) : super(key: key);
  const Rendement({Key? key}) : super(key: key);

  @override
  _RendementState createState() => _RendementState();
  _RendementState createState() => _RendementState();
}

class _RendementState extends State<Rendement> {
  Map<String, List<Modification>> modificationsSemaineDerniere = {};
  Map<String, List<Modification>> modificationsCetteSemaine = {};
  bool isLoading = true;
  String? error;

  final List<String> ordreJours = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];
  Map<String, List<Modification>> modificationsSemaineDerniere = {};
  Map<String, List<Modification>> modificationsCetteSemaine = {};
  bool isLoading = true;
  String? error;

  final List<String> ordreJours = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  @override
  void initState() {
    super.initState();
    fetchRendementJournalier();
  }

  Future<void> fetchRendementJournalier() async {
    try {
      final url =
          Uri.parse('http://192.168.43.194:8000/api/modifications_semaine/');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        Map<String, List<Modification>> tempSemaineDerniere = {};
        Map<String, List<Modification>> tempCetteSemaine = {};

        if (jsonData['semaine_derniere'] is Map<String, dynamic>) {
          final semaineDerniere =
              jsonData['semaine_derniere'] as Map<String, dynamic>;
          semaineDerniere.forEach((jour, listeModsJson) {
            if (listeModsJson is List) {
              tempSemaineDerniere[jour] = listeModsJson
                  .map((modJson) => Modification.fromJson(modJson))
                  .toList();
            }
          });
        }

        if (jsonData['cette_semaine'] is Map<String, dynamic>) {
          final cetteSemaine =
              jsonData['cette_semaine'] as Map<String, dynamic>;
          cetteSemaine.forEach((jour, listeModsJson) {
            if (listeModsJson is List) {
              tempCetteSemaine[jour] = listeModsJson
                  .map((modJson) => Modification.fromJson(modJson))
                  .toList();
            }
          });
        }

        setState(() {
          modificationsSemaineDerniere = tempSemaineDerniere;
          modificationsCetteSemaine = tempCetteSemaine;
          isLoading = false;
          error = null;
        });
      } else {
        setState(() {
          error = 'Erreur serveur: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erreur de chargement: $e';
        isLoading = false;
      });
    }
  }

  List<Widget> _buildListeJours(
      Map<String, List<Modification>> modificationsParJour) {
    final joursTries = modificationsParJour.keys.toList()
      ..sort((a, b) {
        String jourA = a.split(' ').first;
        String jourB = b.split(' ').first;
        return ordreJours.indexOf(jourA).compareTo(ordreJours.indexOf(jourB));
      });

    return joursTries.map((date) {
      final modifications = modificationsParJour[date]!;

      // Afficher la plus récente en haut (ordre inverse du backend)
      final modificationsTriees = modifications.reversed.toList();

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ExpansionTile(
          title: Text(date,
              style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
          children: modificationsTriees.map((mod) {
            return ListTile(
              leading:
                  Icon(mod.type == 'article' ? Icons.article : Icons.extension),
              title: InkWell(
                child: Text(mod.reference, style: GoogleFonts.dmSans()),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => mod.type == 'article'
                          ? Historique(reference: mod.reference)
                          : HistoriqueComposant(reference: mod.reference),
                      builder: (context) => mod.type == 'article'
                          ? Historique(reference: mod.reference)
                          : HistoriqueComposant(reference: mod.reference),
                    ),
                  );
                },
              ),
              // PAS DE TRAILING, PAS DE QUANTITE !
            );
          }).toList(),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rendement journalier', style: GoogleFonts.dmSans()),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(error!,
                      style: GoogleFonts.dmSans(color: Colors.red)))
              : (modificationsSemaineDerniere.isEmpty &&
                      modificationsCetteSemaine.isEmpty)
                  ? Center(
                      child: Text('Aucune modification trouvée',
                          style: GoogleFonts.dmSans()))
                  : ListView(
                      padding: const EdgeInsets.all(8),
                      children: [
                        if (modificationsCetteSemaine.isNotEmpty) ...[
                          Text('Cette semaine',
                              style: GoogleFonts.dmSans(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ..._buildListeJours(modificationsCetteSemaine),
                          const SizedBox(height: 20),
                        ],
                        if (modificationsSemaineDerniere.isNotEmpty) ...[
                          Text('Semaine dernière',
                              style: GoogleFonts.dmSans(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ..._buildListeJours(modificationsSemaineDerniere),
                        ],
                      ],
                    ),
    );
  }
}
