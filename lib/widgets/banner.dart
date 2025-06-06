import 'package:flutter/material.dart';

class BannerWidget extends StatelessWidget {

  final String title;

  const BannerWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const CurvaInversaClipper(),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class CurvaInversaClipper extends CustomClipper<Path> {

  const CurvaInversaClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    // curva en forma de "S" invertida
    path.cubicTo(
      size.width * 0.45, size.height,
      size.width * 0.75, size.height - 80,
      size.width, size.height - 40,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}