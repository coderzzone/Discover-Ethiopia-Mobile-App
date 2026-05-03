import 'package:ethio_explore/app.dart';
import 'package:ethio_explore/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EthioExplore app launches', (WidgetTester tester) async {
    await tester.pumpWidget(EthioExploreApp(state: AppState.fresh()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Categories'), findsOneWidget);
  });
}
