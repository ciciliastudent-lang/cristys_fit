import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:christys_fit/main.dart';

void main() {
  // Pretend to be a phone so everything fits on screen.
  void usephoneScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('Home screen loads with greeting and Tops selected',
      (WidgetTester tester) async {
    usephoneScreen(tester);
    await tester.pumpWidget(const ChristysFitApp());

    expect(find.textContaining('Christy.', findRichText: true), findsOneWidget);
    expect(find.text('Tops · 2 of 4'), findsOneWidget);
    expect(find.text('Choose a top.'), findsOneWidget);
  });

  testWidgets('Arrow buttons change the selected item',
      (WidgetTester tester) async {
    usephoneScreen(tester);
    await tester.pumpWidget(const ChristysFitApp());

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();
    expect(find.text('Tops · 3 of 4'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pump();
    expect(find.text('Tops · 2 of 4'), findsOneWidget);
  });

  testWidgets('Tapping a category switches the wardrobe',
      (WidgetTester tester) async {
    usephoneScreen(tester);
    await tester.pumpWidget(const ChristysFitApp());

    await tester.tap(find.text('Bottoms'));
    await tester.pump();

    expect(find.text('Choose a bottom.'), findsOneWidget);
    expect(find.text('Bottoms · 1 of 4'), findsOneWidget);
  });

  testWidgets('Heart button toggles liked state', (WidgetTester tester) async {
    usephoneScreen(tester);
    await tester.pumpWidget(const ChristysFitApp());

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
