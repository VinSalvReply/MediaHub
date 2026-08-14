import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediahub/core/widgets/page_error.dart';

void main() {
  testWidgets('PageError renders title and retry callback', (
    WidgetTester tester,
  ) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: PageError(
          title: 'Impossibile caricare i dati',
          message: 'Si è verificato un errore durante il caricamento.',
          onRetry: () => pressed = true,
        ),
      ),
    );

    expect(find.text('Impossibile caricare i dati'), findsOneWidget);
    expect(find.text('Riprova'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Riprova'));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
