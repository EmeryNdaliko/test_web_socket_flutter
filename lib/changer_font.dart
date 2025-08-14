import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AutoChangingFontText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color color;
  final Duration changeDuration;

  const AutoChangingFontText({
    super.key,
    required this.text,
    this.fontSize = 20,
    this.color = Colors.black,
    this.changeDuration = const Duration(seconds: 2),
  });

  @override
  State<AutoChangingFontText> createState() => _AutoChangingFontTextState();
}

class _AutoChangingFontTextState extends State<AutoChangingFontText> {
  // Liste des générateurs de TextStyle (chaque élément retourne un TextStyle)
  final List<TextStyle Function(double, Color)> _fonts = [
    (size, color) => GoogleFonts.poppins(fontSize: size, color: color),
    (size, color) => GoogleFonts.montserrat(fontSize: size, color: color),
    (size, color) => GoogleFonts.raleway(fontSize: size, color: color),
    (size, color) => GoogleFonts.lato(fontSize: size, color: color),
    (size, color) => GoogleFonts.nunito(fontSize: size, color: color),
    (size, color) => GoogleFonts.inter(fontSize: size, color: color),
    (size, color) => GoogleFonts.rubik(fontSize: size, color: color),
    (size, color) => GoogleFonts.workSans(fontSize: size, color: color),
    (size, color) => GoogleFonts.bebasNeue(fontSize: size, color: color),
  ];

  int _currentFontIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Change automatiquement la police toutes les X secondes
    _timer = Timer.periodic(widget.changeDuration, (timer) {
      setState(() {
        _currentFontIndex = (_currentFontIndex + 1) % _fonts.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Construire le TextStyle courant en utilisant les paramètres fournis
    final TextStyle currentStyle = _fonts[_currentFontIndex](
      widget.fontSize,
      widget.color,
    );

    return Text(widget.text, style: currentStyle);
  }
}
