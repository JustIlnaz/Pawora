import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawora/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PaworaApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
