import 'package:flutter/widgets.dart';
import '../domain/duty_archive.dart';

class DutyScope extends InheritedNotifier<DutyArchive> {
  const DutyScope({
    super.key,
    required DutyArchive archive,
    required super.child,
  }) : super(notifier: archive);

  static DutyArchive of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DutyScope>();
    assert(scope != null, 'DutyScope not found in context');
    return scope!.notifier!;
  }

  static DutyArchive read(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<DutyScope>()
        ?.widget as DutyScope?;
    return scope!.notifier!;
  }
}
