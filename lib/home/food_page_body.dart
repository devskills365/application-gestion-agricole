import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:food_app/home/widget/smallText.dart';
import 'package:food_app/pages/feed.dart';

class FoodPageBody extends StatefulWidget {
  const FoodPageBody({super.key});

  @override
  State<FoodPageBody> createState() => _FoodPageBodyState();
}

class _FoodPageBodyState extends State<FoodPageBody> {
  final PageController pageController = PageController(viewportFraction: 0.85);
  double _currPageValue = 0.0;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Section du carrousel
          Container(
            height: screenHeight * 0.35,
            child: PageView.builder(
              controller: pageController,
              itemCount: 5,
              itemBuilder: (context, position) {
                return _buildPageItem(position);
              },
            ),
          ),
          DotsIndicator(
            dotsCount: 5,
            position: _currPageValue,
            decorator: DotsDecorator(
              size: const Size.square(9.0),
              activeSize: const Size(18.0, 9.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),

          // Espacement entre les sections
          SizedBox(height: 20),

          // Section des vidéos
          Container(
            margin: EdgeInsets.only(left: screenWidth * 0.08, top: 20),
            child: Row(
              children: [
                SmallText(text: "Vidéos agricoles", color: Colors.black87),
              ],
            ),
          ),

          // Liste des vidéos avec Feed
          SizedBox(
            height: screenHeight * 0.45,
            child: Feed(), // Utilisation du widget Feed
          ),

          // Espacement entre les sections
          SizedBox(height: 20),

          // Nouvelle section d'informations
          Container(
            margin: EdgeInsets.only(left: screenWidth * 0.08, top: 20),
            child: Row(
              children: [
                SmallText(text: "Informations", color: Colors.black87),
              ],
            ),
          ),
          // Description dans cette section
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Notre application vous propose des vidéos informatives et éducatives sur les pratiques agricoles, la culture du cacao et bien plus.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Nous sommes dédiés à fournir des contenus de qualité pour améliorer les pratiques agricoles et soutenir la communauté des agriculteurs.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageItem(int index) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Image de fond avec un léger flou
          Container(
            height: screenHeight * 0.125,
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('img/food03.jpg'),
              ),
            ),
          ),

          // Espacement réduit et fond subtile derrière le texte
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 8,
            ),
            child: Container(
              padding: EdgeInsets.all(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SmallText(text: "Coopérative AGP"),
                  SizedBox(height: 6),
                  Text(
                    "Coopérative AGP regroupe plus de 200 éleveurs. Elle existe depuis 2002. Elle a son siège à Abidjan, dans la commune de Cocody Palmeraie.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
