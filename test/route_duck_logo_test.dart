import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sehir_ici_mikro_lojistik/widgets/route_duck_logo.dart';

void main() {
  testWidgets('RouteDuckLogo "Route" ve özel boyalı "Duck" metinlerini doğru renkle render etmeli', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RouteDuckLogo(
            fontSize: 28,
            suffix: ' Müşteri',
          ),
        ),
      ),
    );

    // Text.rich içerisinde RichText widget'ı aranır
    final richTextFinder = find.byType(RichText);
    expect(richTextFinder, findsOneWidget);

    final richText = tester.widget<RichText>(richTextFinder);
    expect(richText.text.toPlainText(), 'RouteDuck Müşteri');

    // TextSpan hierarchy
    final rootSpan = richText.text as TextSpan;
    final contentSpan = rootSpan.children?.length == 1 && rootSpan.children!.first is TextSpan
        ? rootSpan.children!.first as TextSpan
        : rootSpan;

    expect(contentSpan.children, isNotNull);
    expect(contentSpan.children!.length, 3);

    final routeSpan = contentSpan.children![0] as TextSpan;
    expect(routeSpan.text, 'Route');

    final duckSpan = contentSpan.children![1] as TextSpan;
    expect(duckSpan.text, 'Duck');
    expect(duckSpan.style?.color, const Color(0xFFEDA45F));

    final suffixSpan = contentSpan.children![2] as TextSpan;
    expect(suffixSpan.text, ' Müşteri');
  });
}
