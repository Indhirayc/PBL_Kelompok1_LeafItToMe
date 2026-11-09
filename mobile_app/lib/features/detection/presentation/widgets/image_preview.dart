import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    super.key,
    required this.imageAsset,
    required this.semanticLabel,
    this.source,
    this.aspectRatio = 0.88,
    this.showFrameCorners = true,
    this.padding = 12,
  });

  final String imageAsset;
  final String semanticLabel;
  final String? source;
  final double aspectRatio;
  final bool showFrameCorners;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFF204B35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                semanticLabel: semanticLabel,
              ),
              if (showFrameCorners) const _PhotoFrameCorners(),
              if (source != null)
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sumber: $source',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoFrameCorners extends StatelessWidget {
  const _PhotoFrameCorners();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _PhotoFrameCornersPainter());
  }
}

class _PhotoFrameCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const inset = 10.0;
    const cornerLength = 28.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final corners = <Path>[
      Path()
        ..moveTo(inset + cornerLength, inset)
        ..lineTo(inset, inset)
        ..lineTo(inset, inset + cornerLength),
      Path()
        ..moveTo(size.width - inset - cornerLength, inset)
        ..lineTo(size.width - inset, inset)
        ..lineTo(size.width - inset, inset + cornerLength),
      Path()
        ..moveTo(inset, size.height - inset - cornerLength)
        ..lineTo(inset, size.height - inset)
        ..lineTo(inset + cornerLength, size.height - inset),
      Path()
        ..moveTo(size.width - inset - cornerLength, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset - cornerLength),
    ];

    for (final path in corners) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
