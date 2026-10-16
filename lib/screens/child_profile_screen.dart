import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/child.dart';

class ChildProfileScreen extends StatefulWidget {
  final Child child;

  const ChildProfileScreen({
    super.key,
    required this.child,
  });

  @override
  State<ChildProfileScreen> createState() => _ChildProfileScreenState();
}

class _ChildProfileScreenState extends State<ChildProfileScreen> {
  List<Map<String, dynamic>> vaccinations = [];
  bool loadingVaccines = true;

  @override
  void initState() {
    super.initState();
    loadVaccinations();
  }

  Future<void> loadVaccinations() async {
    if (widget.child.id == null) {
      setState(() {
        loadingVaccines = false;
      });
      return;
    }

    final data = await DatabaseHelper.instance.getVaccinations(
      childId: widget.child.id,
    );

    if (!mounted) return;

    setState(() {
      vaccinations = data;
      loadingVaccines = false;
    });
  }

  Future<void> toggleVaccine(Map<String, dynamic> v) async {
    final vId = v['id'] as int;
    final bool currentStatus = DatabaseHelper.isVaccineCompleted(v['completed']);
    final bool newStatus = !currentStatus;

    await DatabaseHelper.instance.setVaccinationCompleted(vId, newStatus);
    await loadVaccinations();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${v['vaccine']} marked as ${newStatus ? "completed" : "pending"}',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    if (widget.child.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Child?'),
          content: Text(
            'Are you sure you want to permanently remove ${widget.child.name}?\n\n'
            'All data related to this child will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('REMOVE'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await DatabaseHelper.instance.deleteChild(widget.child.id!);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.child.name} removed'),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        title: const Text(
          'Child Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (child.id != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Remove Child',
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // -------------------------------------------------
            // PROFILE HEADER
            // -------------------------------------------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Icon(
                      child.gender == 'Female'
                          ? Icons.girl
                          : Icons.boy,
                      size: 55,
                      color: Colors.deepPurple,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    child.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    child.ageText,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------------------------------
            // BASIC INFORMATION
            // -------------------------------------------------

            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _infoCard(
              icon: Icons.calendar_today_outlined,
              title: 'Date of Birth',
              value:
                  '${child.dateOfBirth.day}/'
                  '${child.dateOfBirth.month}/'
                  '${child.dateOfBirth.year}',
            ),

            _infoCard(
              icon: child.gender == 'Female'
                  ? Icons.female
                  : Icons.male,
              title: 'Gender',
              value: child.gender,
            ),

            _infoCard(
              icon: Icons.person_outline,
              title: "Mother's Name",
              value: child.motherName,
            ),

            _infoCard(
              icon: Icons.phone_outlined,
              title: 'Contact Number',
              value: child.contactNumber,
            ),

            _infoCard(
              icon: Icons.location_on_outlined,
              title: 'Address',
              value: child.address,
            ),

            const SizedBox(height: 20),

            // -------------------------------------------------
            // GROWTH
            // -------------------------------------------------

            const Text(
              'Growth Monitoring',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: _growthCard(
                    icon: Icons.height,
                    title: 'Height',
                    value: '${child.height.toStringAsFixed(1)} cm',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _growthCard(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Weight',
                    value: '${child.weight.toStringAsFixed(1)} kg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // -------------------------------------------------
            // NUTRITION
            // -------------------------------------------------

            const Text(
              'Nutrition & Healthy Foods',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _nutritionCard(
              icon: Icons.restaurant_outlined,
              title: 'Balanced Meals',
              text:
                  'Provide age-appropriate meals containing cereals, pulses, vegetables and other nutritious foods.',
            ),

            _nutritionCard(
              icon: Icons.local_drink_outlined,
              title: 'Hydration',
              text:
                  'Encourage adequate clean drinking water throughout the day.',
            ),

            _nutritionCard(
              icon: Icons.egg_outlined,
              title: 'Protein-rich Foods',
              text:
                  'Include suitable protein-rich foods such as pulses, dairy and other locally available nutritious foods.',
            ),

            const SizedBox(height: 20),

            // -------------------------------------------------
            // IMMUNIZATION SCHEDULE & RECORDS
            // -------------------------------------------------

            const Text(
              'Immunization Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (loadingVaccines)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (vaccinations.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.vaccines_outlined,
                      size: 42,
                      color: Colors.deepPurple.shade300,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'No vaccination records found',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: vaccinations.map((v) {
                  final bool isDone = DatabaseHelper.isVaccineCompleted(v['completed']);
                  final dueDate = DateTime.parse(v['dueDate']);
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
                  final isOverdue = !isDone && dueDay.isBefore(today);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isDone
                              ? Colors.green.shade50
                              : isOverdue
                                  ? Colors.red.shade50
                                  : Colors.orange.shade50,
                          child: Icon(
                            isDone
                                ? Icons.check_circle
                                : isOverdue
                                    ? Icons.warning_amber
                                    : Icons.schedule,
                            color: isDone
                                ? Colors.green
                                : isOverdue
                                    ? Colors.red
                                    : Colors.orange,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                v['vaccine'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isDone,
                          activeTrackColor: Colors.green.shade200,
                          activeThumbColor: Colors.green,
                          onChanged: (_) => toggleVaccine(v),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // INFORMATION CARD
  // ---------------------------------------------------------

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // GROWTH CARD
  // ---------------------------------------------------------

  Widget _growthCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.deepPurple,
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // NUTRITION CARD
  // ---------------------------------------------------------

  Widget _nutritionCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.deepPurple,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
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
