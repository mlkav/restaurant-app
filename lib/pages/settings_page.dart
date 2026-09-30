// lib\pages\settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../reminder/reminder_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildThemeCard(themeProvider),
          const SizedBox(height: 16),
          const DailyReminderTile(),
          const SizedBox(height: 16),
          _buildAboutCard(),
        ],
      ),
    );
  }

  // ================= THEME =================
  Widget _buildThemeCard(ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dark Mode'),
                      SizedBox(height: 4),
                      Text(
                        'Beralih antara tema terang dan gelap',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: themeProvider.toggleTheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('App Version'),
              trailing: Text('2.0.0'),
            ),
            ListTile(
              leading: Icon(Icons.restaurant),
              title: Text('Data Source'),
              trailing: Text('Dicoding API'),
            ),
            ListTile(
              leading: Icon(Icons.code),
              title: Text('Developer'),
              trailing: Text('anone8'),
            ),
          ],
        ),
      ),
    );
  }
}
