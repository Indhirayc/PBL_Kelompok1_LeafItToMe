import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/guide/data/guide_data.dart';
import 'package:mobile_app/features/guide/presentation/pages/guide_detail_page.dart';
import 'package:mobile_app/features/guide/presentation/pages/tool_detail_page.dart';

void main() {
  test('semua alat dan bahan memiliki imageAssetPath dan filenya ada di disk', () {
    final tools = GuideData.tools;
    expect(tools, isNotEmpty);

    for (final tool in tools) {
      expect(tool.imageAssetPath, isNotNull, reason: 'Tool ${tool.id} harus memiliki imageAssetPath');
      expect(tool.imageAssetPath, isNotEmpty, reason: 'Tool ${tool.id} imageAssetPath tidak boleh kosong');

      final file = File(tool.imageAssetPath!);
      expect(
        file.existsSync(),
        isTrue,
        reason: 'File ${tool.imageAssetPath} untuk tool ${tool.id} harus ada di disk',
      );
    }
  });

  testWidgets('ToolDetailPage menampilkan gambar ilustrasi alat', (tester) async {
    final tool = GuideData.tools.firstWhere((t) => t.id == 'benih-tomat');

    await tester.pumpWidget(
      MaterialApp(
        home: ToolDetailPage(tool: tool),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Benih Tomat Unggul'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('GuideDetailPage menampilkan thumbnail gambar alat dan bahan', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GuideDetailPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tab default adalah Alat & Bahan
    expect(find.text('Alat & Bahan'), findsWidgets);
    expect(find.text('Pot Tanam / Polybag'), findsOneWidget);
    expect(find.text('Benih Tomat Unggul'), findsOneWidget);
    expect(find.text('Media Tanam Subur'), findsOneWidget);
    expect(find.text('Sprayer & Alat Penyiram'), findsOneWidget);
    expect(find.text('Ajir Tanaman (Penyangga)'), findsOneWidget);
    expect(find.text('Pupuk Organik & NPK'), findsOneWidget);

    // Semua 6 item alat/bahan memiliki widget Image thumbnail
    expect(find.byType(Image), findsNWidgets(6));
  });
}
