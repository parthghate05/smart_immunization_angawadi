import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/child.dart';
import 'add_child_screen.dart';
import 'profile_screen.dart';

// =========================================================
// DASHBOARD
// =========================================================

class DashboardScreen extends StatefulWidget {
  final String workerName;
  final String username;

  const DashboardScreen({
    super.key,
    required this.workerName,
    required this.username,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Child> children = [];
  List<Map<String, dynamic>> vaccines = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // =========================================================
  // LOAD DATABASE DATA
  // =========================================================

  Future<void> loadData() async {
    final childData =
    await DatabaseHelper.instance.getChildren();

    final vaccineData =
    await DatabaseHelper.instance.getVaccinations(
      pendingOnly: true,
    );

    if (!mounted) return;

    setState(() {
      children = childData;
      vaccines = vaccineData;
    });
  }

  // =========================================================
  // ADD CHILD
  // =========================================================

  Future<void> addChild() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddChildScreen(),
      ),
    );

    if (result == true) {
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final growthRecorded = children
        .where(
          (child) =>
      child.height > 0 &&
          child.weight > 0,
    )
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    workerName: widget.workerName,
                    username: widget.username,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.account_circle_outlined,
            ),
          ),
        ],
      ),

      // =====================================================
      // BODY
      // =====================================================

      body: RefreshIndicator(
        onRefresh: loadData,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [

            // =================================================
            // GREETING
            // =================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFCE4EC),
                    Color(0xFFF3E5F5),
                  ],
                ),

                borderRadius:
                BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Namaste 🙏',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    widget.workerName,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Let's keep our children healthy!",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // =================================================
            // OVERVIEW
            // =================================================

            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: statCard(
                    children.length.toString(),
                    'Total Children',
                    Icons.child_care,
                    Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: statCard(
                    vaccines.length.toString(),
                    'Pending Vaccines',
                    Icons.vaccines,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: statCard(
                    growthRecorded.toString(),
                    'Growth Recorded',
                    Icons.favorite,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // =================================================
            // UPCOMING VACCINATIONS
            // =================================================

            const Text(
              'Upcoming Vaccinations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (vaccines.isEmpty)
              Container(
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(16),
                ),

                child: const Column(
                  children: [

                    Icon(
                      Icons.event_available,
                      size: 45,
                      color: Colors.deepPurple,
                    ),

                    SizedBox(height: 10),

                    Text(
                      'No upcoming vaccinations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Vaccination reminders will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...vaccines.take(5).map(vaccineCard),

            const SizedBox(height: 25),

            // =================================================
            // REGISTER CHILD
            // =================================================


            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget statCard(
      String number,
      String title,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: color,
            size: 30,
          ),

          const SizedBox(height: 10),

          Text(
            number,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // VACCINE CARD
  // =========================================================

  Widget vaccineCard(
      Map<String, dynamic> vaccine,
      ) {
    final childId = vaccine['childId'];

    String childName = 'Child';

    for (final child in children) {
      if (child.id == childId) {
        childName = child.name;
        break;
      }
    }

    final date =
    DateTime.parse(vaccine['dueDate']);

    final days =
        date.difference(DateTime.now()).inDays;

    final dueText = days < 0
        ? 'Overdue'
        : days == 0
        ? 'Due today'
        : 'Due in $days days';

    return Container(
      margin:
      const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
            Colors.deepPurple.shade50,

            child: const Icon(
              Icons.vaccines,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  childName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  vaccine['vaccine'].toString(),
                ),

                const SizedBox(height: 4),

                Text(
                  dueText,
                  style: TextStyle(
                    color: days < 0
                        ? Colors.red
                        : Colors.deepOrange,

                    fontSize: 12,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}