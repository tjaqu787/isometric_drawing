// In quick_settings.dart
import 'package:flutter/material.dart';
import './settings_tab.dart';
import './measurement_tab.dart';

class QuickSettingsWindow extends StatefulWidget {
  const QuickSettingsWindow({super.key});

  @override
  State<QuickSettingsWindow> createState() => _QuickSettingsWindowState();
}

class _QuickSettingsWindowState extends State<QuickSettingsWindow>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTabBar(context),
            const SizedBox(height: 8),
            Expanded(child: _buildTabBarView()),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  TabBar _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Measurements'),
        Tab(text: 'Settings'),
      ],
      labelColor: Theme.of(context).colorScheme.primary,
      indicatorColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: const [
        MeasurementsTab(),
        SettingsTab(),
      ],
    );
  }
}
