import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sofima/articles/articles.dart';
import 'package:sofima/add/addarticle.dart';
import 'package:sofima/admin/admin.dart';
import 'package:sofima/rendement/rendement.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  FlutterSecureStorage storage = FlutterSecureStorage();
  String userType = "";

  // Cette fonction vérifie le type d'utilisateur
  Future<void> veriftypeUser() async {
    String? admin = await storage.read(key: "admin");
    String? superadmin = await storage.read(key: "superadmin");
    String? utilisateur = await storage.read(key: "utilisateur");
    print("Navigation: $admin , $superadmin , $utilisateur");

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

  @override
  void initState() {
    super.initState();
    veriftypeUser(); // Vérifie le type d'utilisateur au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Acceuil",
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
      body: ListView(
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreen()));
                      },
                      child: Image.asset(
                        "assets/accueil-2.png",
                        height: 100,
                        width: 100,
                      )),
                  Text(
                    "Articles",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              if (userType == "admin" || userType == "superadmin")
                Column(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Rendement()));
                        },
                        child: Image.asset(
                          "assets/rendement.png",
                          height: 100,
                          width: 100,
                        )),
                    Text(
                      "Rendement",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
            ],
          ),
          SizedBox(
            height: 100,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddArticle()));
                      },
                      child: Image.asset(
                        "assets/plus-2.png",
                        height: 100,
                        width: 100,
                      )),
                  Text(
                    "Ajouter un Article",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ],
          ),
          // Ajouter un quatrième bouton si l'utilisateur est un admin ou superadmin
          if (userType == "admin" || userType == "superadmin") ...[
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Admin()));
                      },
                      child: Image.asset(
                        "assets/users.png", // Utilise une icône différente pour ce bouton
                        height: 100,
                        width: 100,
                      ),
                    ),
                    Text(
                      "Admin Actions",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
