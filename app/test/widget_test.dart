import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/app.dart';

void main() {
  testWidgets('App should render login button by default', (WidgetTester tester) async {
    await tester.pumpWidget(const GoApiApp());
    await tester.pump();

    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
