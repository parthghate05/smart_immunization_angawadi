import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/child.dart';
import 'add_child_screen.dart';
import 'child_profile_screen.dart';

// =========================================================
// CHILDREN SCREEN
// =========================================================

class ChildrenScreen extends StatefulWidget {
  final VoidCallback? onChanged;

  const ChildrenScreen({
    super.key,
    this.onChanged,
  });

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  List<Child> children = [];
  String search = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadChildren();
  }

  // =========================================================
  // LOAD CHILDREN FROM DATABASE
  // =========================================================

  Future<void> loadChildren() async {
    final data = await DatabaseHelper.instance.getChildren();

    if (!mounted) return;

    setState(() {
      children = data;
      loading = false;
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
      await loadChildren();
      widget.onChanged?.call();
    }
  }

  // =========================================================
  // DELETE CHILD
  // =========================================================

  Future<void> deleteChild(Child child) async {
    if (child.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Child?'),
          content: Text(
            'Are you sure you want to permanently remove '
                '${child.name}?\n\n'
                'All data related to this child will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('REMOVE'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await DatabaseHelper.instance.deleteChild(child.id!);

    await loadChildren();
    widget.onChanged?.call();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${child.name} removed'),
      ),
    );
  }

  // =========================================================
  // SEARCH
  // =========================================================

  List<Child> get filteredChildren {
    if (search.trim().isEmpty) {
      return children;
    }

    return children.where((child) {
      final query = search.toLowerCase();

      return child.name.toLowerCase().contains(query) ||
          child.motherName.toLowerCase().contains(query);
    }).toList();
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final filtered = filteredChildren;

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
          'Children',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

      ),

      // =====================================================
      // ADD CHILD BUTTON
      // =====================================================

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addChild,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Child'),
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
          // SEARCH BAR
          // =================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search child or mother',
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.deepPurple,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // =================================================
          // CHILD LIST / EMPTY STATE
          // =================================================

          Expanded(
            child: filtered.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.child_care_outlined,
                      size: 70,
                      color: Colors.deepPurple.shade200,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      children.isEmpty
                          ? 'No children registered'
                          : 'No child found',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      children.isEmpty
                          ? 'Tap Add Child to register the first child.'
                          : 'Try another name.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: loadChildren,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  100,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final child = filtered[index];

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      // Child icon
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor:
                        Colors.deepPurple.shade50,
                        child: const Icon(
                          Icons.child_care,
                          color: Colors.deepPurple,
                        ),
                      ),

                      // Child information
                      title: Text(
                        child.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Padding(
                        padding:
                        const EdgeInsets.only(top: 5),
                        child: Text(
                          '${child.ageText} • ${child.gender}',
                        ),
                      ),

                      // Open profile
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ChildProfileScreen(
                                        child: child,
                                      ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),

                          // Delete
                          IconButton(
                            onPressed: () {
                              deleteChild(child);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}