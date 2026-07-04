import 'package:flutter_test/flutter_test.dart';

import 'package:unima_library_catalogue/main.dart';

void main() {
  testWidgets('UNIMA catalogue shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(const UnimaLibraryApp());

    await tester.pump();

    expect(find.text('UNIMA Library Catalogue'), findsOneWidget);
    expect(find.text('Student Search'), findsOneWidget);
    expect(find.text('Librarian Login'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation'));
    await tester.pumpAndSettle();

    expect(find.text('Catalogue'), findsWidgets);
    expect(find.text('Schools'), findsWidgets);
    expect(find.text('Library Services'), findsOneWidget);
  });
}
