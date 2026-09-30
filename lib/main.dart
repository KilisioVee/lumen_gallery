import 'package:flutter/material.dart';
import 'package:gallery_walkthrough/presentation/pages/gallery_page.dart';

void main() => runApp(const GalleryApp());

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Gallerie Walk.',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF876443)),
    ),
    home: const GalleryPage(),
  );
}




















