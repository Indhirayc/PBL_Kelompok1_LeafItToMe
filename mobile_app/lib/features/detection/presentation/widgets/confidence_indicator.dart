import 'package:flutter/material.dart';

class ConfidenceIndicator extends StatelessWidget {
  const ConfidenceIndicator({
    super.key,
    required this.percentage,
    this.isExample = false,
  });

  final int percentage;
  final bool isExample;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F7338),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '${isExample ? 'Contoh akurasi' : 'Akurasi'} $percentage%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
