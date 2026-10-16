import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/child.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Child> children = [];
  List<Map<String, dynamic>> vaccinations = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  // =========================================================
  // LOAD REPORT DATA
  // =========================================================

  Future<void> loadReports() async {
    setState(() {
      loading = true;
    });

    final childData =
    await DatabaseHelper.instance.getChildren();

    final vaccineData =
    await DatabaseHelper.instance.getVaccinations();

    if (!mounted) return;

    setState(() {
      children = childData;
      vaccinations = vaccineData;
      loading = false;
    });
  }

  // =========================================================
  // CHILD STATISTICS
  // =========================================================

  int get maleCount {
    return children
        .where((child) => child.gender == 'Male')
        .length;
  }

  int get femaleCount {
    return children
        .where((child) => child.gender == 'Female')
        .length;
  }

  int get growthRecorded {
    return children
        .where(
          (child) =>
      child.height > 0 &&
          child.weight > 0,
    )
        .length;
  }

  // =========================================================
  // VACCINATION STATISTICS
  // =========================================================

  int get totalVaccines {
    return vaccinations.length;
  }

  int get completedVaccines {
    return vaccinations
        .where(
          (vaccine) => DatabaseHelper.isVaccineCompleted(vaccine['completed']),
        )
        .length;
  }

  int get pendingVaccines {
    return vaccinations
        .where(
          (vaccine) => !DatabaseHelper.isVaccineCompleted(vaccine['completed']),
        )
        .length;
  }

  int get overdueVaccines {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return vaccinations.where((vaccine) {
      if (DatabaseHelper.isVaccineCompleted(vaccine['completed'])) {
        return false;
      }

      final dueDateStr = vaccine['dueDate']?.toString();
      if (dueDateStr == null || dueDateStr.isEmpty) return false;

      final dueDate = DateTime.tryParse(dueDateStr);
      if (dueDate == null) return false;

      final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
      return dueDay.isBefore(today);
    }).length;
  }

  double get vaccinationPercentage {
    if (totalVaccines == 0) {
      return 0;
    }

    return (completedVaccines / totalVaccines) * 100;
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: loadReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: loadReports,

        child: ListView(
          padding: const EdgeInsets.all(16),

          children: [

            // =================================================
            // REPORT INTRO
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

              child: Row(
                children: [

                  Container(
                    padding:
                    const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.bar_chart,
                      color: Colors.deepPurple,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Reports & Statistics',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Overview of children, growth and immunization.',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // OVERALL STATISTICS
            // =================================================

            const Text(
              'Overall Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _statCard(
                    number:
                    children.length.toString(),
                    title: 'Total Children',
                    icon: Icons.child_care,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    number:
                    maleCount.toString(),
                    title: 'Male',
                    icon: Icons.male,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _statCard(
                    number:
                    femaleCount.toString(),
                    title: 'Female',
                    icon: Icons.female,
                    color: Colors.pink,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    number:
                    growthRecorded.toString(),
                    title: 'Growth Recorded',
                    icon: Icons.monitor_weight,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // =================================================
            // IMMUNIZATION REPORT
            // =================================================

            const Text(
              'Immunization Report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _statCard(
                    number:
                    totalVaccines.toString(),
                    title: 'Total Records',
                    icon: Icons.vaccines,
                    color: Colors.deepPurple,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    number:
                    completedVaccines.toString(),
                    title: 'Completed',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _statCard(
                    number:
                    pendingVaccines.toString(),
                    title: 'Pending',
                    icon: Icons.schedule,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _statCard(
                    number:
                    overdueVaccines.toString(),
                    title: 'Overdue',
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // =================================================
            // VACCINATION COMPLETION
            // =================================================

            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: [

                      const Text(
                        'Vaccination Completion',
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        '${vaccinationPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          color:
                          Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value:
                    vaccinationPercentage /
                        100,

                    minHeight: 9,

                    borderRadius:
                    BorderRadius.circular(
                      10,
                    ),

                    backgroundColor:
                    Colors.grey.shade200,

                    color: Colors.deepPurple,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '$completedVaccines of '
                        '$totalVaccines vaccination records completed.',
                    style: TextStyle(
                      color:
                      Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =================================================
            // REPORT SUMMARY
            // =================================================

            const Text(
              'Report Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(18),
              ),

              child: Column(
                children: [

                  _summaryRow(
                    Icons.people,
                    'Registered Children',
                    children.length.toString(),
                  ),

                  const Divider(height: 25),

                  _summaryRow(
                    Icons.height,
                    'Growth Records',
                    growthRecorded.toString(),
                  ),

                  const Divider(height: 25),

                  _summaryRow(
                    Icons.vaccines,
                    'Vaccinations Completed',
                    completedVaccines.toString(),
                  ),

                  const Divider(height: 25),

                  _summaryRow(
                    Icons.schedule,
                    'Vaccinations Pending',
                    pendingVaccines.toString(),
                  ),

                  const Divider(height: 25),

                  _summaryRow(
                    Icons.warning_amber,
                    'Vaccinations Overdue',
                    overdueVaccines.toString(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget _statCard({
    required String number,
    required String title,
    required IconData icon,
    required Color color,
  }) {
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
            size: 29,
          ),

          const SizedBox(height: 10),

          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

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
  // SUMMARY ROW
  // =========================================================

  Widget _summaryRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      children: [

        Icon(
          icon,
          color: Colors.deepPurple,
          size: 24,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}