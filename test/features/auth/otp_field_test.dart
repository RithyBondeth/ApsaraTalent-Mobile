import 'package:apsaratalent_mobile/core/themes/app_theme.dart';
import 'package:apsaratalent_mobile/features/auth/presentation/widgets/otp_field.dart';
import 'package:apsaratalent_mobile/features/auth/providers/otp/otp_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;
  late List<String> completed;

  Future<void> pump(WidgetTester tester) async {
    container = ProviderContainer();
    completed = [];
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(body: OtpField(onCompleted: completed.add)),
        ),
      ),
    );
  }

  testWidgets('takes a whole code delivered at once, as autofill and paste do',
      (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), '221310');
    await tester.pump();

    expect(container.read(otpProvider).otp, '221310');
    expect(completed, ['221310']);
    for (final digit in ['2', '1', '3', '0']) {
      expect(find.text(digit), findsWidgets);
    }
  });

  testWidgets('never paints the theme input fill over the boxes', (tester) async {
    await pump(tester);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.filled, isFalse);
  });

  testWidgets('keeps every digit typed one after another', (tester) async {
    await pump(tester);

    var typed = '';
    for (final digit in '482915'.split('')) {
      typed += digit;
      await tester.enterText(find.byType(TextField), typed);
    }
    await tester.pump();

    expect(container.read(otpProvider).otp, '482915');
    expect(completed, ['482915']);
  });

  testWidgets('drops non-digits and anything past the code length',
      (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), '12-34 5678');
    await tester.pump();

    expect(container.read(otpProvider).otp, '123456');
  });

  testWidgets('empties the boxes when the notifier is cleared', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();

    container.read(otpProvider.notifier).clear();
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.text('1'), findsNothing);
  });
}
