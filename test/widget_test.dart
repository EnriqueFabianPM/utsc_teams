// Este es un smoke test simple para verificar que la app monta la pantalla inicial.
// Ajusta los textos si cambias los títulos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:utsc_teams/app.dart'; // <- Importa la app real, no main.dart

void main() {
  testWidgets('La app carga la pantalla de inicio del estudiante',
          (WidgetTester tester) async {
        // Construye la app
        await tester.pumpWidget(const UtscTeamsApp());

        // Verifica que aparece el título del AppBar de la pantalla inicial
        expect(find.text('Inicio (Estudiante)'), findsOneWidget);

        // También podemos verificar que hay exactamente un Scaffold
        expect(find.byType(Scaffold), findsOneWidget);
      });
}
