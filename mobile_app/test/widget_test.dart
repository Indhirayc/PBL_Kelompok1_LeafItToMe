import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('Splash screen menampilkan identitas LeafItToMe', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(debugShowCheckedModeBanner: false, home: SplashPage()),
    );

    await tester.pump();

    expect(find.text('LeafItToMe'), findsOneWidget);
    expect(find.text('Kenali Daunnya, Jaga Tanamannya'), findsOneWidget);
    expect(find.text('Memuat...'), findsOneWidget);

    expect(find.text('Flutter Demo Home Page'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);

    // Menghapus SplashPage sebelum timer menjalankan GoRouter.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
