import 'package:flutter_test/flutter_test.dart';

import 'package:food_web_builder/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodWebApp());
    await tester.pumpAndSettle();

    expect(find.text('Food Web Builder'), findsOneWidget);
    expect(find.text('Jogar'), findsOneWidget);
    expect(find.text('Ranking'), findsOneWidget);
    expect(find.text('Sobre'), findsOneWidget);
  });
}
