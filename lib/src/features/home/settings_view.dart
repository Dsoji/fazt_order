import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/app_colors.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kcPrimaryNeutral950,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text('Settings'),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
        )
      );
  }
}
