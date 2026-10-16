import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/child.dart';

class ImmunizationScreen extends StatefulWidget {
  const ImmunizationScreen({super.key});

  @override
  State<ImmunizationScreen> createState() =>
      _ImmunizationScreenState();
}

class _ImmunizationScreenState
    extends State<ImmunizationScreen> {

  final TextEditingController searchController =
  TextEditingController();

  List<Child> children = [];

  List<Map<String, dynamic>> vaccinations = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVaccinations();
  }

  // =========================================================
  // LOAD REAL DATA FROM DATABASE
  // =========================================================

  Future<void> loadVaccinations() async {
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
  // SEARCH
  // =========================================================

  List<Map<String, dynamic>> get filteredVaccinations {

    final query =
    searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return vaccinations;
    }

    return vaccinations.where((vaccine) {

      final vaccineName =
      vaccine['vaccine']
          .toString()
          .toLowerCase();

      final childId = vaccine['childId'];

      String childName = '';

      for (final child in children) {
        if (child.id == childId) {
          childName = child.name.toLowerCase();
          break;
        }
      }

      return vaccineName.contains(query) ||
          childName.contains(query);

    }).toList();
  }

  // =========================================================
  // FIND CHILD NAME
  // =========================================================

  String getChildName(int childId) {

    for (final child in children) {

      if (child.id == childId) {
        return child.name;
      }

    }

    return 'Unknown Child';
  }

  // =========================================================
  // MARK VACCINE COMPLETE
  // =========================================================

  Future<void> markComplete(
      Map<String, dynamic> vaccine) async {

    final vaccineId = vaccine['id'];

    await DatabaseHelper.instance
        .markVaccinationComplete(vaccineId);

    await loadVaccinations();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${vaccine['vaccine']} marked as completed',
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    final filtered =
        filteredVaccinations;

    final upcoming = filtered
        .where(
          (item) => !DatabaseHelper.isVaccineCompleted(item['completed']),
        )
        .toList();

    final completed = filtered
        .where(
          (item) => DatabaseHelper.isVaccineCompleted(item['completed']),
        )
        .toList();

    return Scaffold(
      backgroundColor:
      const Color(0xFFF8F7FC),

      // =====================================================
      // APP BAR
      // =====================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          'Immunization',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

      ),

      // =====================================================
      // BODY
      // =====================================================

      body: loading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : Column(
        children: [

          // =================================================
          // SEARCH
          // =================================================

          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              10,
            ),

            child: TextField(
              controller:
              searchController,

              onChanged: (_) {
                setState(() {});
              },

              decoration:
              InputDecoration(
                hintText:
                'Search child or vaccine',

                prefixIcon:
                const Icon(
                  Icons.search,
                  color:
                  Colors.deepPurple,
                ),

                suffixIcon:
                searchController
                    .text
                    .isNotEmpty
                    ? IconButton(
                  icon:
                  const Icon(
                    Icons.clear,
                  ),
                  onPressed: () {
                    searchController
                        .clear();

                    setState(() {});
                  },
                )
                    : null,

                filled: true,
                fillColor: Colors.white,

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),
          ),

          // =================================================
          // LIST
          // =================================================

          Expanded(
            child: RefreshIndicator(
              onRefresh:
              loadVaccinations,

              child: ListView(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  5,
                  16,
                  100,
                ),

                children: [

                  // =================================================
                  // UPCOMING
                  // =================================================

                  const Text(
                    'Upcoming Vaccinations',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (upcoming.isEmpty)

                    _emptyCard(
                      Icons.event_available,
                      'No upcoming vaccinations',
                      'All vaccinations are completed.',
                    )

                  else

                    ...upcoming.map(
                          (vaccine) =>
                          _vaccinationCard(
                            vaccine,
                            false,
                          ),
                    ),

                  const SizedBox(
                    height: 20,
                  ),

                  // =================================================
                  // COMPLETED
                  // =================================================

                  const Text(
                    'Vaccination Records',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (completed.isEmpty)

                    _emptyCard(
                      Icons.vaccines_outlined,
                      'No completed vaccinations',
                      'Completed vaccination records will appear here.',
                    )

                  else

                    ...completed.map(
                          (vaccine) =>
                          _vaccinationCard(
                            vaccine,
                            true,
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

  // =========================================================
  // VACCINATION CARD
  // =========================================================

  Widget _vaccinationCard(
      Map<String, dynamic> vaccine,
      bool completed,
      ) {

    final childId =
    vaccine['childId'] as int;

    final childName =
    getChildName(childId);

    final dueDate =
    DateTime.parse(
      vaccine['dueDate'],
    );

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final vaccineDay = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    final difference =
        vaccineDay
            .difference(today)
            .inDays;

    String dateText;

    if (completed) {

      dateText =
      'Completed • ${dueDate.day}/'
          '${dueDate.month}/'
          '${dueDate.year}';

    } else if (difference < 0) {

      dateText =
      'Overdue by ${difference.abs()} days';

    } else if (difference == 0) {

      dateText = 'Due today';

    } else {

      dateText =
      'Due in $difference days';

    }

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
      const EdgeInsets.all(15),

      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(17),
      ),

      child: Row(
        children: [

          // =================================================
          // ICON
          // =================================================

          CircleAvatar(
            radius: 24,

            backgroundColor:
            completed
                ? Colors.green.shade50
                : difference < 0
                ? Colors.red.shade50
                : Colors.orange.shade50,

            child: Icon(
              completed
                  ? Icons.check_circle
                  : difference < 0
                  ? Icons.warning_amber
                  : Icons.schedule,

              color: completed
                  ? Colors.green
                  : difference < 0
                  ? Colors.red
                  : Colors.orange,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          // =================================================
          // INFORMATION
          // =================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  childName,

                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  vaccine['vaccine']
                      .toString(),

                  style:
                  const TextStyle(
                    color:
                    Colors.deepPurple,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  dateText,

                  style: TextStyle(
                    color: completed
                        ? Colors.green
                        : difference < 0
                        ? Colors.red
                        : Colors.orange,

                    fontSize: 12,

                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // =================================================
          // COMPLETE BUTTON
          // =================================================

          if (!completed)
            IconButton(
              tooltip:
              'Mark as completed',

              onPressed: () {
                markComplete(vaccine);
              },

              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // EMPTY CARD
  // =========================================================

  Widget _emptyCard(
      IconData icon,
      String title,
      String subtitle,
      ) {

    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(25),

      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),

      child: Column(
        children: [

          Icon(
            icon,
            size: 45,
            color: Colors.deepPurple,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,

            style:
            const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            subtitle,

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}