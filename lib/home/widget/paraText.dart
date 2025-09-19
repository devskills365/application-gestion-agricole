import 'package:flutter/material.dart';

class ParaText extends StatelessWidget {
  final Color? color;
  final String text;
  final double size;
  final TextOverflow overFlow;

  const ParaText({
    Key? key,
    this.color = const Color.fromARGB(221, 189, 196, 191),
    required this.text,
    this.overFlow = TextOverflow.ellipsis,
    this.size = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: overFlow,
      style: TextStyle(
        color: color ?? Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: size,
      ),
    );
  }
}
