import 'package:flutter/material.dart';
import 'package:food_app/home/food_page_body.dart';
import 'package:food_app/home/widget/big_text.dart';
import 'package:food_app/home/widget/smallText.dart';
import '../pages/scan_page.dart';

class MainFoodPage extends StatefulWidget {
  const MainFoodPage({super.key});

  @override
  State<MainFoodPage> createState() => _MainFoodPageState();
}

class _MainFoodPageState extends State<MainFoodPage> {
  // Ajouter un index pour suivre l'élément sélectionné
  int _selectedIndex = 0;

  // Fonction pour changer l'écran en fonction de l'index
  void _onItemTapped(int index) {
    if (index == 1) {
      // 👉 Si on clique sur "Scan"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScanPage()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BigText(text: "Ziin", color: Color.fromARGB(132, 3, 173, 43)),
                Row(
                  children: [
                    SmallText(text: "Abidjan"),
                    const Icon(Icons.arrow_drop_down_rounded),
                  ],
                ),
              ],
            ),
            Center(
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(132, 3, 173, 43),
                ),
                child: const Icon(Icons.search, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Container(color: Colors.white, child: FoodPageBody()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Indice de l'élément sélectionné
        onTap: _onItemTapped, // Change l'écran quand un élément est sélectionné
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Icône pour "Accueil"
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt), // Icône pour "Scan"
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined), // Icône pour "Partenaire"
            label: 'Partenaire',
          ),
        ],
        selectedItemColor: Color.fromARGB(132, 3, 173, 43),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
