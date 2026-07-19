import 'package:flutter/material.dart';
import 'package:simple_live_app/app/app_style.dart';

class SettingsSwitch extends StatelessWidget {
  final bool value;
  final String title;
  final String? subtitle;
  final Function(bool) onChanged;
  const SettingsSwitch({
    required this.value,
    required this.title,
    this.subtitle,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppStyle.radius12,
      ),
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 24),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.grey),
            )
          : null,
      value: value,
      onChanged: onChanged,
    );
  }
}
