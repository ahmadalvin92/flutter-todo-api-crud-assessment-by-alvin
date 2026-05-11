import 'package:flutter_test/flutter_test.dart';
import 'package:todo_alvin/main.dart';

void main() {
  testWidgets('menampilkan navigasi utama Todo Alvin', (tester) async {
    await tester.pumpWidget(const TodoAlvinApp());

    expect(find.text('Todo Alvin'), findsOneWidget);
    expect(find.text('Todo Lokal'), findsWidgets);
    expect(find.text('Todo API'), findsWidgets);
  });
}
