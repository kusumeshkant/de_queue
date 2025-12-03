import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Common"),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.language,
              title: "Language",
              value: "English",
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.cloud_outlined,
              title: "Environment",
              value: "Production",
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.devices_other,
              title: "Platform",
              value: "Default",
              onTap: () {},
            ),
            _buildSwitchTile(
              icon: Icons.color_lens_outlined,
              title: "Enable custom theme",
              value: false,
              onChanged: (val) {},
            ),
          ]),
          const SizedBox(height: 25),
          _buildSectionTitle("Account"),
          _buildSettingsGroup([
            _buildSettingsTile(
              icon: Icons.phone,
              title: "Phone number",
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.email,
              title: "Email",
              onTap: () {},
            ),
            _buildSettingsTile(
              icon: Icons.logout,
              title: "Sign out",
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 25),
          _buildSectionTitle("Security"),
          _buildSettingsGroup([
            _buildSwitchTile(
              icon: Icons.lock_outline,
              title: "Lock app in background",
              value: true,
              onChanged: (val) {},
            ),
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: "Use fingerprint",
              value: true,
              onChanged: (val) {},
            ),
          ]),
          const SizedBox(height: 15),
          _buildSettingsGroup([
            _buildSwitchTile(
              icon: Icons.password,
              title: "Change password",
              value: true,
              onChanged: (val) {},
            ),
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: "Enable notifications",
              value: true,
              onChanged: (val) {},
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
