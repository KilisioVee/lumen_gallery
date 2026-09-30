import 'package:flutter/material.dart';

class Panel extends StatelessWidget {
  const Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xF5FFFCF5),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
            color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 4)),
      ],
    ),
    child: child,
  );
}