import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lost_and_found/app/lost_found_app.dart';
import 'package:lost_and_found/features/lost_found/views/widgets/dashboard_header.dart';
import 'package:lost_and_found/features/lost_found/views/widgets/item_browser.dart';

Future<void> pumpLostFoundApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(const MainApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders dashboard metrics and seeded item list', (tester) async {
    await pumpLostFoundApp(tester);

    expect(find.text('Lost and Found'), findsOneWidget);
    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Terselesaikan'), findsOneWidget);
    expect(find.text('Laptop Lenovo ThinkPad'), findsWidgets);
  });

  testWidgets('search and type filter change visible results', (tester) async {
    await pumpLostFoundApp(tester);

    await tester.enterText(
      find.byKey(const ValueKey('itemSearchField')),
      'dompet',
    );
    await tester.pumpAndSettle();

    expect(find.text('Dompet Kulit Cokelat'), findsWidgets);
    expect(find.text('Laptop Lenovo ThinkPad'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('filterFound')));
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada hasil'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('filterLost')));
    await tester.pumpAndSettle();

    expect(find.text('Dompet Kulit Cokelat'), findsWidgets);
  });

  testWidgets('add report flow inserts a new item', (tester) async {
    await pumpLostFoundApp(tester);

    await tester.tap(find.byKey(const ValueKey('addReportButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('reportTitleField')),
      'Headset Hitam',
    );
    await tester.enterText(
      find.byKey(const ValueKey('reportLocationField')),
      'Ruang Podcast',
    );
    await tester.enterText(
      find.byKey(const ValueKey('reportReporterField')),
      'Sari Anggraini',
    );
    await tester.enterText(
      find.byKey(const ValueKey('reportContactField')),
      'sari@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('reportDescriptionField')),
      'Headset tertinggal setelah rekaman siang.',
    );

    await tester.tap(find.byKey(const ValueKey('submitReportButton')));
    await tester.pumpAndSettle();

    expect(find.text('Headset Hitam'), findsWidgets);
    expect(find.text('Ruang Podcast'), findsWidgets);
  });

  testWidgets('status action updates selected item state', (tester) async {
    await pumpLostFoundApp(tester);

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('detailStatusLabel')),
        matching: find.text('Klaim Ditinjau'),
      ),
      findsOneWidget,
    );

    final returnedButton = find.byKey(const ValueKey('status-returned'));
    await tester.ensureVisible(returnedButton);
    await tester.tap(returnedButton);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('detailStatusLabel')),
        matching: find.text('Dikembalikan'),
      ),
      findsOneWidget,
    );
    expect(find.text('Status diubah menjadi Dikembalikan'), findsOneWidget);
  });

  testWidgets('mobile layout shows bottom navigation and hides type chips', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    // Verify MetricsGrid is shown and ItemBrowser is hidden initially on Beranda
    expect(find.byType(MetricsGrid), findsOneWidget);
    expect(find.byType(ItemBrowser), findsNothing);
    // Verify FAB is hidden on Beranda mobile
    expect(find.byKey(const ValueKey('addReportButton')), findsNothing);
    // Verify title in appBar is 'Beranda'
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Beranda')), findsOneWidget);

    // Verify NavigationBar is visible and contains the tabs
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Beranda'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Ditemukan'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Hilang'),
      ),
      findsOneWidget,
    );

    // Tap 'Ditemukan' tab
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Ditemukan'),
      ),
    );
    await tester.pumpAndSettle();

    // Verify MetricsGrid is now hidden and ItemBrowser is shown
    expect(find.byType(MetricsGrid), findsNothing);
    expect(find.byType(ItemBrowser), findsOneWidget);
    // Verify FAB is visible on Ditemukan page mobile
    expect(find.byKey(const ValueKey('addReportButton')), findsOneWidget);
    // Verify title in appBar is 'Ditemukan'
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Ditemukan')), findsOneWidget);
    // Verify ChoiceChips for types are not visible inside ItemBrowser
    expect(find.byKey(const ValueKey('filterAllTypes')), findsNothing);

    // Verify list updates (should hide lost items e.g. Dompet Kulit Cokelat)
    expect(find.text('Laptop Lenovo ThinkPad'), findsWidgets);
    expect(find.text('Dompet Kulit Cokelat'), findsNothing);

    // Tap 'Hilang' tab
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Hilang'),
      ),
    );
    await tester.pumpAndSettle();

    // Verify MetricsGrid is hidden and ItemBrowser is shown
    expect(find.byType(MetricsGrid), findsNothing);
    expect(find.byType(ItemBrowser), findsOneWidget);
    // Verify title in appBar is 'Hilang'
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Hilang')), findsOneWidget);

    // Verify list updates (should show lost items and hide found ones)
    expect(find.text('Dompet Kulit Cokelat'), findsWidgets);
    expect(find.text('Laptop Lenovo ThinkPad'), findsNothing);
  });

  testWidgets('edit report flow updates item details', (tester) async {
    await pumpLostFoundApp(tester);

    expect(find.descendant(
      of: find.byKey(const ValueKey('detailPanel')),
      matching: find.text('Laptop Lenovo ThinkPad'),
    ), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('editReportButton')));
    await tester.pumpAndSettle();

    final titleField = find.byKey(const ValueKey('reportTitleField'));
    expect(tester.widget<TextFormField>(titleField).controller?.text, 'Laptop Lenovo ThinkPad');
    
    await tester.enterText(titleField, 'Laptop Lenovo ThinkPad PRO');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('submitReportButton')));
    await tester.pumpAndSettle();

    expect(find.descendant(
      of: find.byKey(const ValueKey('detailPanel')),
      matching: find.text('Laptop Lenovo ThinkPad PRO'),
    ), findsOneWidget);
    expect(find.text('Laporan diperbarui'), findsOneWidget);
  });
}
