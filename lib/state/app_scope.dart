import 'package:flutter/widgets.dart';

import 'app_state.dart';

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<AppStateScope>();
    final widget = element?.widget as AppStateScope?;
    assert(widget != null, 'AppStateScope not found in widget tree');
    return widget!.notifier!;
  }
}
