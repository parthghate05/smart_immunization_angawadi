import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'screens/login_screen.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartImmunizationApp());
}


class AppData extends ChangeNotifier {
  final List<Child> children = [
    Child(
      id: 'CH-001',
      name: 'Aarav Sharma',
      dob: DateTime(2024, 1, 15),
      gender: 'Male',
      mother: 'Priya Sharma',
      phone: '9876543210',
      vaccines: [
        VaccineRecord('BCG', DateTime(2024, 1, 15), true),
        VaccineRecord('OPV-0', DateTime(2024, 1, 15), true),
        VaccineRecord('Pentavalent-1', DateTime(2024, 3, 15), true),
        VaccineRecord('OPV-1', DateTime(2024, 3, 15), true),
        VaccineRecord('Pentavalent-2', DateTime(2024, 4, 15), true),
        VaccineRecord('MR-1', DateTime(2025, 1, 15), false),
      ],
      weight: 10.2,
      height: 79,
      status: 'Healthy',
    ),
    Child(
      id: 'CH-002',
      name: 'Anaya Patil',
      dob: DateTime(2023, 10, 3),
      gender: 'Female',
      mother: 'Sneha Patil',
      phone: '9820123456',
      vaccines: [
        VaccineRecord('BCG', DateTime(2023, 10, 3), true),
        VaccineRecord('OPV-0', DateTime(2023, 10, 3), true),
        VaccineRecord('Pentavalent-1', DateTime(2023, 12, 3), true),
        VaccineRecord('Pentavalent-2', DateTime(2024, 1, 3), true),
        VaccineRecord('Pentavalent-3', DateTime(2024, 2, 3), true),
        VaccineRecord('MR-1', DateTime(2024, 10, 3), true),
      ],
      weight: 11.1,
      height: 83,
      status: 'Healthy',
    ),
    Child(
      id: 'CH-003',
      name: 'Vihaan Khan',
      dob: DateTime(2024, 5, 20),
      gender: 'Male',
      mother: 'Ayesha Khan',
      phone: '9819001122',
      vaccines: [
        VaccineRecord('BCG', DateTime(2024, 5, 20), true),
        VaccineRecord('OPV-0', DateTime(2024, 5, 20), true),
        VaccineRecord('Pentavalent-1', DateTime(2024, 7, 20), true),
        VaccineRecord('Pentavalent-2', DateTime(2024, 8, 20), true),
        VaccineRecord('Pentavalent-3', DateTime(2024, 9, 20), true),
        VaccineRecord('MR-1', DateTime(2025, 5, 20), false),
      ],
      weight: 9.4,
      height: 73,
      status: 'Follow-up',
    ),
  ];

  final List<Reminder> reminders = [
    Reminder('MR-1', 'Aarav Sharma', DateTime(2026, 8, 24), 'Due Soon'),
    Reminder('MR-1', 'Vihaan Khan', DateTime(2026, 8, 28), 'Upcoming'),
    Reminder('Vitamin A', 'Anaya Patil', DateTime(2026, 8, 25), 'Due Soon'),
  ];

  bool notificationsEnabled = true;
  String selectedLanguage = 'English';
  int currentTab = 0;

  int get totalChildren => children.length;
  int get dueSoon => reminders.where((r) => r.status == 'Due Soon').length;
  int get followUps => children.where((c) => c.status == 'Follow-up').length;

  void addChild(Child child) {
    children.add(child);
    notifyListeners();
  }

  void updateChild(Child child) {
    final i = children.indexWhere((c) => c.id == child.id);
    if (i >= 0) children[i] = child;
    notifyListeners();
  }

  void toggleNotifications() {
    notificationsEnabled = !notificationsEnabled;
    notifyListeners();
  }

  void setLanguage(String value) {
    selectedLanguage = value;
    notifyListeners();
  }

  void markReminderDone(Reminder reminder) {
    reminders.remove(reminder);
    notifyListeners();
  }
}

class Child {
  String id;
  String name;
  DateTime dob;
  String gender;
  String mother;
  String phone;
  List<VaccineRecord> vaccines;
  double weight;
  double height;
  String status;

  Child({
    required this.id,
    required this.name,
    required this.dob,
    required this.gender,
    required this.mother,
    required this.phone,
    required this.vaccines,
    required this.weight,
    required this.height,
    required this.status,
  });

  int get completedVaccines => vaccines.where((v) => v.completed).length;
  int get totalVaccines => vaccines.length;
  double get vaccineProgress =>
      totalVaccines == 0 ? 0 : completedVaccines / totalVaccines;
}

class VaccineRecord {
  final String name;
  final DateTime date;
  bool completed;
  VaccineRecord(this.name, this.date, this.completed);
}

class Reminder {
  final String vaccine;
  final String child;
  final DateTime date;
  final String status;
  Reminder(this.vaccine, this.child, this.date, this.status);
}

class SmartImmunizationApp extends StatefulWidget {
  const SmartImmunizationApp({super.key});

  @override
  State<SmartImmunizationApp> createState() => _SmartImmunizationAppState();
}

class _SmartImmunizationAppState extends State<SmartImmunizationApp> {
  final AppData data = AppData();

  @override
  void initState() {
    super.initState();
    data.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    data.removeListener(_refresh);
    data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Immunization',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF087F5B),
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('mr'),
      ],
      home: const SplashScreen(),
    );
  }
}

class MainShell extends StatefulWidget {
  final AppData data;
  const MainShell({super.key, required this.data});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  final titles = const ['Dashboard', 'Children', 'Reminders', 'Reports'];

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(data: widget.data, onTab: (i) => setState(() => index = i)),
      ChildrenPage(data: widget.data),
      RemindersPage(data: widget.data),
      ReportsPage(data: widget.data),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[index], style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => showNotifications(context, widget.data),
            icon: Badge(
              isLabelVisible: widget.data.dueSoon > 0,
              label: Text('${widget.data.dueSoon}'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsPage(data: widget.data)),
                );
              } else if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: 'Smart Immunization',
                  applicationVersion: '1.0.0',
                  applicationLegalese: 'Designed for Anganwadi Centre workflows.',
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'about', child: Text('About')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      floatingActionButton: index == 1
          ? FloatingActionButton.extended(
              onPressed: () => showAddChildDialog(context, widget.data),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Child'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.child_care_outlined), selectedIcon: Icon(Icons.child_care), label: 'Children'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'Reminders'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final AppData data;
  final ValueChanged<int> onTab;
  const DashboardPage({super.key, required this.data, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEE, d MMM yyyy').format(DateTime.now());
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          Text(today, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
          const SizedBox(height: 6),
          const SizedBox(height: 18),
          _OverviewCard(data: data),
          const SizedBox(height: 18),
          _SectionTitle(title: 'Today’s priorities', action: 'View all', onTap: () => onTab(2)),
          const SizedBox(height: 10),
          ...data.reminders.take(3).map((r) => _ReminderTile(reminder: r, data: data)),
          const SizedBox(height: 18),
          _SectionTitle(title: 'Children health snapshot', action: 'View children', onTap: () => onTab(1)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _MiniStat(icon: Icons.child_care, value: '${data.totalChildren}', label: 'Registered')),
              const SizedBox(width: 10),
              Expanded(child: _MiniStat(icon: Icons.check_circle_outline, value: '${data.totalChildren - data.followUps}', label: 'Healthy')),
              const SizedBox(width: 10),
              Expanded(child: _MiniStat(icon: Icons.medical_services_outlined, value: '${data.followUps}', label: 'Follow-up')),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.lightbulb_outline, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Tip: Record weight and height regularly to identify growth concerns early.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final AppData data;
  const _OverviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Immunization overview', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 5),
            Text('${data.dueSoon} vaccinations need attention',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: data.totalChildren == 0 ? 0 : (data.totalChildren - data.followUps) / data.totalChildren,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.white24,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text('${data.totalChildren - data.followUps} of ${data.totalChildren} children currently on track',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class ChildrenPage extends StatefulWidget {
  final AppData data;
  const ChildrenPage({super.key, required this.data});

  @override
  State<ChildrenPage> createState() => _ChildrenPageState();
}

class _ChildrenPageState extends State<ChildrenPage> {
  String query = '';
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final list = widget.data.children.where((c) {
      final matchesText = c.name.toLowerCase().contains(query.toLowerCase()) ||
          c.id.toLowerCase().contains(query.toLowerCase());
      final matchesFilter = filter == 'All' ||
          (filter == 'Follow-up' && c.status == 'Follow-up') ||
          (filter == 'Healthy' && c.status == 'Healthy');
      return matchesText && matchesFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: const InputDecoration(
              hintText: 'Search child by name or ID',
              prefixIcon: Icon(Icons.search),
              suffixIcon: Icon(Icons.tune),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: ['All', 'Healthy', 'Follow-up'].map((f) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: filter == f,
                  onSelected: (_) => setState(() => filter = f),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('No children found'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _ChildCard(child: list[i], data: widget.data),
                ),
        ),
      ],
    );
  }
}

class _ChildCard extends StatelessWidget {
  final Child child;
  final AppData data;
  const _ChildCard({required this.child, required this.data});

  @override
  Widget build(BuildContext context) {
    final initials = child.name.split(' ').map((e) => e[0]).take(2).join();
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChildDetailsPage(child: child, data: data)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 3),
                    Text('${child.id} • ${child.gender}'),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: child.vaccineProgress,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${child.completedVaccines}/${child.totalVaccines}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(child.status == 'Healthy' ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: child.status == 'Healthy' ? Colors.green : Colors.orange),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildDetailsPage extends StatefulWidget {
  final Child child;
  final AppData data;
  const ChildDetailsPage({super.key, required this.child, required this.data});

  @override
  State<ChildDetailsPage> createState() => _ChildDetailsPageState();
}

class _ChildDetailsPageState extends State<ChildDetailsPage> {
  late Child child;

  @override
  void initState() {
    super.initState();
    child = widget.child;
  }

  void editHealth() async {
    final weight = TextEditingController(text: child.weight.toString());
    final height = TextEditingController(text: child.height.toString());
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update health measurements'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: weight, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg)')),
            const SizedBox(height: 12),
            TextField(controller: height, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (result == true) {
      setState(() {
        child.weight = double.tryParse(weight.text) ?? child.weight;
        child.height = double.tryParse(height.text) ?? child.height;
      });
      widget.data.updateChild(child);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Health record updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(child.dob).inDays ~/ 365;
    return Scaffold(
      appBar: AppBar(title: Text(child.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    child: Text(child.name[0], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Text(child.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  Text('${child.id} • $age years'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoPill(icon: Icons.person_outline, text: child.gender),
                      _InfoPill(icon: Icons.family_restroom, text: child.mother),
                      _InfoPill(icon: Icons.phone_outlined, text: child.phone),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _DetailSection(
            title: 'Growth monitoring',
            action: 'Edit',
            onAction: editHealth,
            child: Row(
              children: [
                Expanded(child: _GrowthBox(label: 'Weight', value: '${child.weight.toStringAsFixed(1)} kg')),
                const SizedBox(width: 10),
                Expanded(child: _GrowthBox(label: 'Height', value: '${child.height.toStringAsFixed(0)} cm')),
                const SizedBox(width: 10),
                Expanded(child: _GrowthBox(label: 'Status', value: child.status)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailSection(
            title: 'Vaccination record',
            child: Column(
              children: child.vaccines.map((v) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: v.completed ? Colors.green.shade50 : Colors.orange.shade50,
                    child: Icon(v.completed ? Icons.check : Icons.schedule,
                        color: v.completed ? Colors.green : Colors.orange),
                  ),
                  title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(DateFormat('d MMM yyyy').format(v.date)),
                  trailing: Switch(
                    value: v.completed,
                    onChanged: (value) {
                      setState(() => v.completed = value);
                      widget.data.updateChild(child);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => showAddHealthNote(context, child, widget.data),
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Add health note'),
          ),
        ],
      ),
    );
  }
}

class RemindersPage extends StatelessWidget {
  final AppData data;
  const RemindersPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.reminders.isEmpty) {
      return const Center(child: Text('All reminders are completed 🎉'));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_outlined, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.notificationsEnabled
                        ? 'Reminders are enabled for this centre.'
                        : 'Reminders are currently paused.',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Switch(value: data.notificationsEnabled, onChanged: (_) => data.toggleNotifications()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...data.reminders.map((r) => _ReminderTile(reminder: r, data: data, detailed: true)),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final AppData data;
  final bool detailed;
  const _ReminderTile({required this.reminder, required this.data, this.detailed = false});

  @override
  Widget build(BuildContext context) {
    final isDue = reminder.status == 'Due Soon';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: isDue ? Colors.orange.shade50 : Colors.blue.shade50,
          child: Icon(Icons.vaccines_outlined, color: isDue ? Colors.orange : Colors.blue),
        ),
        title: Text('${reminder.vaccine} • ${reminder.child}', style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('Due ${DateFormat('d MMM yyyy').format(reminder.date)}'),
        trailing: detailed
            ? PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'done') {
                    data.markReminderDone(reminder);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder marked complete')));
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'done', child: Text('Mark complete')),
                  PopupMenuItem(value: 'call', child: Text('Call parent')),
                ],
              )
            : Chip(label: Text(reminder.status)),
      ),
    );
  }
}

class ReportsPage extends StatelessWidget {
  final AppData data;
  const ReportsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final completed = data.children.fold<int>(0, (sum, c) => sum + c.completedVaccines);
    final total = data.children.fold<int>(0, (sum, c) => sum + c.totalVaccines);
    final progress = total == 0 ? 0.0 : completed / total;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Centre immunization coverage', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 18),
                SizedBox(
                  height: 150,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 130,
                          height: 130,
                          child: CircularProgressIndicator(value: progress, strokeWidth: 14),
                        ),
                        Text('${(progress * 100).round()}%',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                Center(child: Text('$completed completed vaccine records out of $total')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _ReportTile(icon: Icons.people_alt_outlined, title: 'Registered children', value: '${data.totalChildren}'),
        _ReportTile(icon: Icons.event_available_outlined, title: 'Upcoming reminders', value: '${data.reminders.length}'),
        _ReportTile(icon: Icons.warning_amber_outlined, title: 'Children needing follow-up', value: '${data.followUps}'),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => showReportDialog(context),
          icon: const Icon(Icons.file_download_outlined),
          label: const Text('Generate centre report'),
        ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  final AppData data;
  const SettingsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SettingsHeader(title: 'Preferences'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Vaccination reminders'),
                  subtitle: const Text('Show due and upcoming reminders'),
                  value: data.notificationsEnabled,
                  onChanged: (_) => data.toggleNotifications(),
                ),
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text('Language'),
                  subtitle: Text(data.selectedLanguage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showLanguageDialog(context, data),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _SettingsHeader(title: 'Centre'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text('Centre location'),
                  subtitle: Text('Anganwadi Centre • Mumbai'),
                ),
                ListTile(
                  leading: const Icon(Icons.sync_outlined),
                  title: const Text('Data status'),
                  subtitle: const Text('Local records ready for sync'),
                  trailing: TextButton(onPressed: () => showSyncDialog(context), child: const Text('Sync')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  const _SettingsHeader({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;
  const _SectionTitle({required this.title, required this.action, required this.onTap});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
      TextButton(onPressed: onTap, child: Text(action)),
    ],
  );
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _MiniStat({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 7),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    ),
  );
}

class _GrowthBox extends StatelessWidget {
  final String label;
  final String value;
  const _GrowthBox({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoPill({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(text)],
    ),
  );
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Widget child;
  const _DetailSection({required this.title, this.action, this.onAction, required this.child});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
              if (action != null) TextButton(onPressed: onAction, child: Text(action!)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    ),
  );
}

class _ReportTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _ReportTile({required this.icon, required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
    ),
  );
}

void showNotifications(BuildContext context, AppData data) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (data.reminders.isEmpty)
            const Padding(padding: EdgeInsets.all(20), child: Text('No pending notifications')),
          ...data.reminders.map((r) => _ReminderTile(reminder: r, data: data, detailed: true)),
        ],
      ),
    ),
  );
}

void showAddChildDialog(BuildContext context, AppData data) {
  final name = TextEditingController();
  final mother = TextEditingController();
  final phone = TextEditingController();
  String gender = 'Male';
  DateTime dob = DateTime.now().subtract(const Duration(days: 365));

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (_, setDialog) => AlertDialog(
        title: const Text('Register new child'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Child name')),
              const SizedBox(height: 10),
              TextField(controller: mother, decoration: const InputDecoration(labelText: 'Mother / guardian')),
              const SizedBox(height: 10),
              TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Parent phone')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setDialog(() => gender = v ?? gender),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date of birth'),
                subtitle: Text(DateFormat('d MMM yyyy').format(dob)),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    firstDate: DateTime(2018),
                    lastDate: DateTime.now(),
                    initialDate: dob,
                  );
                  if (picked != null) setDialog(() => dob = picked);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              data.addChild(
                Child(
                  id: 'CH-${(data.children.length + 1).toString().padLeft(3, '0')}',
                  name: name.text.trim(),
                  dob: dob,
                  gender: gender,
                  mother: mother.text.trim().isEmpty ? 'Not provided' : mother.text.trim(),
                  phone: phone.text.trim().isEmpty ? 'Not provided' : phone.text.trim(),
                  vaccines: [
                    VaccineRecord('BCG', dob, false),
                    VaccineRecord('OPV-0', dob, false),
                    VaccineRecord('Pentavalent-1', dob.add(const Duration(days: 60)), false),
                    VaccineRecord('Pentavalent-2', dob.add(const Duration(days: 90)), false),
                    VaccineRecord('Pentavalent-3', dob.add(const Duration(days: 120)), false),
                    VaccineRecord('MR-1', dob.add(const Duration(days: 365)), false),
                  ],
                  weight: 0,
                  height: 0,
                  status: 'Healthy',
                ),
              );
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Child registered successfully')));
            },
            child: const Text('Register'),
          ),
        ],
      ),
    ),
  );
}

void showAddHealthNote(BuildContext context, Child child, AppData data) {
  final note = TextEditingController();
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Add health note'),
      content: TextField(
        controller: note,
        maxLines: 4,
        decoration: const InputDecoration(hintText: 'Enter observation, concern or follow-up note'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(note.text.trim().isEmpty ? 'Note not added' : 'Health note saved for ${child.name}')),
            );
          },
          child: const Text('Save note'),
        ),
      ],
    ),
  );
}

void showLanguageDialog(BuildContext context, AppData data) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Choose language'),
      content: RadioGroup<String>(
        groupValue: data.selectedLanguage,
        onChanged: (v) {
          if (v != null) {
            data.setLanguage(v);
            Navigator.pop(context);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'हिन्दी', 'मराठी']
              .map((v) => RadioListTile<String>(value: v, title: Text(v)))
              .toList(),
        ),
      ),
    ),
  );
}

void showSyncDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Data sync'),
      content: const Text('Demo mode: local records are ready to be synchronized when a backend is connected.'),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
    ),
  );
}

void showReportDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Centre report'),
      content: const Text('Report generation is available in this prototype. Connect your preferred PDF/export service to persist the generated report.'),
      actions: [FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
    ),
  );
}
