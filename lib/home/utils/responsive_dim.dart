// Fichier: lib/utils/responsive_dim.dart
import 'package:get/get.dart';

class ResponsiveDim {
  static double screenWidth = Get.context!.height;
  static double screenHeight = Get.context!.width;
  static double pageViewController = screenHeight / 1.04;
  static double pageView = screenHeight / 0.8;
  static double pageViewTextController = screenWidth / 2.03;
}
