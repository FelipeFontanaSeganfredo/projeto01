import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projeto01/components/editor.dart';

void main() {
  testWidgets('Editor exibe o rótulo informado', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Editor(
            controlador: TextEditingController(),
            rotulo: 'Nome',
            dica: 'Digite o nome',
          ),
        ),
      ),
    );

    expect(find.text('Nome'), findsOneWidget);
  });
}
