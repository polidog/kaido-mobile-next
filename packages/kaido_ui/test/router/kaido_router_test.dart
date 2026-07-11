import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaido_ui/pages/contact_map_page.dart';
import 'package:kaido_ui/pages/contact_page.dart';
import 'package:kaido_ui/pages/copyright_page.dart';
import 'package:kaido_ui/pages/html_page.dart';
import 'package:kaido_ui/pages/image_page.dart';
import 'package:kaido_ui/pages/info_page.dart';
import 'package:kaido_ui/pages/map_page.dart';
import 'package:kaido_ui/pages/settings_page.dart';
import 'package:kaido_ui/pages/splash_page.dart';
import 'package:kaido_ui/router/kaido_router.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, String location) async {
    final router = createKaidoRouter(initialLocation: location);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('/ resolves to MapPage', (tester) async {
    await pumpAt(tester, '/');
    expect(find.byType(MapPage), findsOneWidget);
  });

  testWidgets('/info/:id resolves to InfoPage', (tester) async {
    await pumpAt(tester, '/info/42');
    final infoPage = tester.widget<InfoPage>(find.byType(InfoPage));
    expect(infoPage.id, '42');
  });

  testWidgets('/info/:id/image resolves to ImagePage', (tester) async {
    await pumpAt(tester, '/info/42/image');
    final imagePage = tester.widget<ImagePage>(find.byType(ImagePage));
    expect(imagePage.id, '42');
  });

  testWidgets('/settings resolves to SettingsPage', (tester) async {
    await pumpAt(tester, '/settings');
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('/contact resolves to ContactPage', (tester) async {
    await pumpAt(tester, '/contact');
    expect(find.byType(ContactPage), findsOneWidget);
  });

  testWidgets('/contact/map resolves to ContactMapPage', (tester) async {
    await pumpAt(tester, '/contact/map');
    expect(find.byType(ContactMapPage), findsOneWidget);
  });

  testWidgets('/html/:page resolves to HtmlPage', (tester) async {
    await pumpAt(tester, '/html/help');
    final htmlPage = tester.widget<HtmlPage>(find.byType(HtmlPage));
    expect(htmlPage.page, 'help');
  });

  testWidgets('/copyright resolves to CopyrightPage', (tester) async {
    await pumpAt(tester, '/copyright');
    expect(find.byType(CopyrightPage), findsOneWidget);
  });

  testWidgets('/splash resolves to SplashPage', (tester) async {
    await pumpAt(tester, '/splash');
    expect(find.byType(SplashPage), findsOneWidget);
  });

  testWidgets('unknown route triggers errorBuilder', (tester) async {
    await pumpAt(tester, '/does-not-exist');
    expect(find.text('エラー'), findsOneWidget);
  });
}
