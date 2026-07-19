import 'package:flutter/material.dart';
import 'package:simple_live_app/app/app_style.dart';

class SettingsCard extends StatelessWidget {
  final Widget child;
  const SettingsCard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: AppStyle.radius12,
        side: BorderSide(
          color: Colors.grey.withAlpha(25),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppStyle.radius12,
        ),
        child: child,
      ),
    );
  }
}
