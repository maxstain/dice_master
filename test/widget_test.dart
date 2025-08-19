import 'package:dice_master/features/splash/splash_screen.dart';
import 'package:dice_master/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  testWidgets('Splash Screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DiceMasterApp());
    await tester.pumpAndSettle(); // Wait for animations to complete
    // Verify that the splash screen is displayed
    expect(find.byType(SplashScreen), findsOneWidget);
    // Verify that the Lottie animation is present
    expect(find.byType(Lottie), findsOneWidget);
    // Verify that the splash screen has a specific text
    expect(find.text('Dice Master'), findsOneWidget);
  });
}
