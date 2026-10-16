import 'package:flutter/material.dart';

import 'login_screen.dart';

// =========================================================
// PROFILE
// =========================================================

class ProfileScreen extends StatelessWidget {
  final String workerName;
  final String username;

  const ProfileScreen({
    super.key,
    required this.workerName,
    required this.username,
  });

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          const SizedBox(height: 20),

          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFFEDE7F6),
            child: Icon(
              Icons.person,
              size: 55,
              color: Colors.deepPurple,
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              workerName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 5),

          const Center(
            child: Text(
              'Anganwadi Worker',
              style: TextStyle(color: Colors.black54),
            ),
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),

            child: Column(
              children: [
                infoRow(
                  Icons.person_outline,
                  'Worker Name',
                  workerName,
                ),

                const Divider(height: 30),

                infoRow(
                  Icons.badge_outlined,
                  'Username',
                  username,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 55,

            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,

                  builder: (_) => AlertDialog(
                    title: const Text('Logout'),

                    content: const Text(
                      'Are you sure you want to logout?',
                    ),

                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          logout(context);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),

                        child: const Text('LOGOUT'),
                      ),
                    ],
                  ),
                );
              },

              icon: const Icon(Icons.logout),

              label: const Text(
                'LOGOUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // PROFILE INFORMATION
  // =========================================================

  Widget infoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.deepPurple,
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}