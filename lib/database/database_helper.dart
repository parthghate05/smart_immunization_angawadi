import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/child.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  Database? _database;
  bool _isSyncing = false;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    startFirestoreSync();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();

    final path = join(
      databasesPath,
      'smart_anganwadi_v2.db',
    );

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute(
          'PRAGMA foreign_keys = ON',
        );
      },
      onCreate: (db, version) async {
        // ---------------- LOGIN ----------------

        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            workerName TEXT NOT NULL
          )
        ''');

        await db.insert(
          'users',
          {
            'username': 'admin',
            'password': '1234',
            'workerName': 'Anganwadi Worker',
          },
        );

        // ---------------- CHILDREN ----------------

        await db.execute('''
          CREATE TABLE children (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            dateOfBirth TEXT NOT NULL,
            gender TEXT NOT NULL,
            motherName TEXT NOT NULL,
            contactNumber TEXT NOT NULL,
            address TEXT NOT NULL,
            height REAL NOT NULL DEFAULT 0,
            weight REAL NOT NULL DEFAULT 0
          )
        ''');

        // ---------------- GROWTH ----------------

        await db.execute('''
          CREATE TABLE growth_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            childId INTEGER NOT NULL,
            date TEXT NOT NULL,
            height REAL NOT NULL,
            weight REAL NOT NULL,

            FOREIGN KEY(childId)
            REFERENCES children(id)
            ON DELETE CASCADE
          )
        ''');

        // ---------------- VACCINATIONS ----------------

        await db.execute('''
          CREATE TABLE vaccinations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            childId INTEGER NOT NULL,
            vaccine TEXT NOT NULL,
            dueDate TEXT NOT NULL,
            completed INTEGER NOT NULL DEFAULT 0,
            reminderSent INTEGER NOT NULL DEFAULT 0,

            FOREIGN KEY(childId)
            REFERENCES children(id)
            ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // =========================================================
  // HELPER FOR COMPLETED PARSING
  // =========================================================

  static int parseCompleted(dynamic val) {
    if (val == null) return 0;
    if (val is bool) return val ? 1 : 0;
    if (val is num) return val.toInt() == 1 ? 1 : 0;
    if (val is String) {
      final s = val.trim().toLowerCase();
      if (s == '1' || s == 'true') return 1;
    }
    return 0;
  }

  static bool isVaccineCompleted(dynamic val) {
    return parseCompleted(val) == 1;
  }

  // =========================================================
  // FIREBASE FIRESTORE REAL-TIME SYNC
  // =========================================================

  void startFirestoreSync({VoidCallback? onDataChanged}) {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Listen to children collection changes from Firestore
      FirebaseFirestore.instance
          .collection('children')
          .snapshots()
          .listen((snapshot) async {
        final db = await database;

        for (var change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null) continue;

          final childId = (data['id'] as num?)?.toInt();
          if (childId == null) continue;

          if (change.type == DocumentChangeType.removed) {
            await db.delete(
              'children',
              where: 'id = ?',
              whereArgs: [childId],
            );
          } else {
            final row = {
              'id': childId,
              'name': data['name'] ?? '',
              'dateOfBirth': data['dateOfBirth'] ??
                  DateTime.now().toIso8601String(),
              'gender': data['gender'] ?? 'Male',
              'motherName': data['motherName'] ?? '',
              'contactNumber': data['contactNumber'] ?? '',
              'address': data['address'] ?? '',
              'height': (data['height'] as num?)?.toDouble() ?? 0.0,
              'weight': (data['weight'] as num?)?.toDouble() ?? 0.0,
            };

            await db.insert(
              'children',
              row,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        onDataChanged?.call();
      }, onError: (e) {
        debugPrint('Firestore children sync error: $e');
      });

      // Listen to vaccinations collection changes from Firestore
      FirebaseFirestore.instance
          .collection('vaccinations')
          .snapshots()
          .listen((snapshot) async {
        final db = await database;

        for (var change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null) continue;

          final vaccineId = (data['id'] as num?)?.toInt();
          if (vaccineId == null) continue;

          if (change.type == DocumentChangeType.removed) {
            await db.delete(
              'vaccinations',
              where: 'id = ?',
              whereArgs: [vaccineId],
            );
          } else {
            final row = {
              'id': vaccineId,
              'childId': (data['childId'] as num?)?.toInt() ?? 0,
              'vaccine': data['vaccine'] ?? '',
              'dueDate': data['dueDate'] ??
                  DateTime.now().toIso8601String(),
              'completed': parseCompleted(data['completed']),
              'reminderSent': (data['reminderSent'] as num?)?.toInt() ?? 0,
            };

            await db.insert(
              'vaccinations',
              row,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
        onDataChanged?.call();
      }, onError: (e) {
        debugPrint('Firestore vaccinations sync error: $e');
      });
    } catch (e) {
      debugPrint('Firestore init sync error: $e');
    }
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanUsername == 'admin' && cleanPassword == '1234') {
      return {
        'id': 1,
        'username': 'admin',
        'password': '1234',
        'workerName': 'Anganwadi Worker',
      };
    }

    final db = await database;

    final result = await db.query(
      'users',
      where: 'LOWER(username) = ? AND password = ?',
      whereArgs: [
        cleanUsername,
        cleanPassword,
      ],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // =========================================================
  // CHILDREN
  // =========================================================

  Future<List<Child>> getChildren() async {
    final db = await database;

    final result = await db.query(
      'children',
      orderBy: 'name COLLATE NOCASE ASC',
    );

    return result
        .map(
          (row) => Child.fromMap(row),
        )
        .toList();
  }

  Future<int> insertChild(Child child) async {
    final db = await database;

    final childId = await db.transaction<int>(
      (transaction) async {
        final id = await transaction.insert(
          'children',
          {
            'name': child.name,
            'dateOfBirth': child.dateOfBirth.toIso8601String(),
            'gender': child.gender,
            'motherName': child.motherName,
            'contactNumber': child.contactNumber,
            'address': child.address,
            'height': child.height,
            'weight': child.weight,
          },
        );

        // Save initial growth measurement
        await transaction.insert(
          'growth_records',
          {
            'childId': id,
            'date': DateTime.now().toIso8601String(),
            'height': child.height,
            'weight': child.weight,
          },
        );

        // Generate vaccination schedule
        final schedule = _generateVaccineSchedule(
          child.dateOfBirth,
        );

        for (final vaccine in schedule) {
          await transaction.insert(
            'vaccinations',
            {
              'childId': id,
              'vaccine': vaccine['name'],
              'dueDate': (vaccine['date'] as DateTime).toIso8601String(),
              'completed': 0,
              'reminderSent': 0,
            },
          );
        }

        return id;
      },
    );

    // Sync child and its generated vaccinations to Firestore
    _syncChildToFirestore(childId);

    return childId;
  }

  Future<void> _syncChildToFirestore(int childId) async {
    try {
      final db = await database;

      // Sync Child document
      final childRows = await db.query(
        'children',
        where: 'id = ?',
        whereArgs: [childId],
      );

      if (childRows.isNotEmpty) {
        final childData = childRows.first;
        await FirebaseFirestore.instance
            .collection('children')
            .doc(childId.toString())
            .set(childData);
      }

      // Sync Vaccination documents
      final vRows = await db.query(
        'vaccinations',
        where: 'childId = ?',
        whereArgs: [childId],
      );

      for (var row in vRows) {
        final vId = row['id'];
        await FirebaseFirestore.instance
            .collection('vaccinations')
            .doc(vId.toString())
            .set(row);
      }
    } catch (e) {
      debugPrint('Error pushing child to Firestore: $e');
    }
  }

  // =========================================================
  // DELETE CHILD COMPLETELY
  // =========================================================

  Future<void> deleteChild(int childId) async {
    final db = await database;

    // Delete locally
    await db.delete(
      'children',
      where: 'id = ?',
      whereArgs: [childId],
    );

    // Sync deletion to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('children')
          .doc(childId.toString())
          .delete();

      final vSnap = await FirebaseFirestore.instance
          .collection('vaccinations')
          .where('childId', isEqualTo: childId)
          .get();

      for (var doc in vSnap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting child from Firestore: $e');
    }
  }

  Future<int> getChildCount() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM children',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // =========================================================
  // GROWTH
  // =========================================================

  Future<void> addGrowthRecord({
    required int childId,
    required double height,
    required double weight,
  }) async {
    final db = await database;

    await db.insert(
      'growth_records',
      {
        'childId': childId,
        'date': DateTime.now().toIso8601String(),
        'height': height,
        'weight': weight,
      },
    );

    await db.update(
      'children',
      {
        'height': height,
        'weight': weight,
      },
      where: 'id = ?',
      whereArgs: [childId],
    );

    // Sync updated child height/weight to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('children')
          .doc(childId.toString())
          .update({
        'height': height,
        'weight': weight,
      });
    } catch (e) {
      debugPrint('Error updating growth in Firestore: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGrowthRecords(
    int childId,
  ) async {
    final db = await database;

    return await db.query(
      'growth_records',
      where: 'childId = ?',
      whereArgs: [childId],
      orderBy: 'date DESC',
    );
  }

  // =========================================================
  // VACCINES
  // =========================================================

  Future<List<Map<String, dynamic>>> getVaccinations({
    int? childId,
    bool pendingOnly = false,
  }) async {
    final db = await database;

    String? where;
    List<Object?>? args;

    if (childId != null) {
      where = 'childId = ?';
      args = [childId];

      if (pendingOnly) {
        where += ' AND completed = 0';
      }
    } else if (pendingOnly) {
      where = 'completed = 0';
    }

    return await db.query(
      'vaccinations',
      where: where,
      whereArgs: args,
      orderBy: 'dueDate ASC',
    );
  }

  Future<void> setVaccinationCompleted(
    int vaccineId,
    bool isCompleted,
  ) async {
    final db = await database;
    final int val = isCompleted ? 1 : 0;

    await db.update(
      'vaccinations',
      {
        'completed': val,
      },
      where: 'id = ?',
      whereArgs: [vaccineId],
    );

    // Sync to Firestore
    try {
      await FirebaseFirestore.instance
          .collection('vaccinations')
          .doc(vaccineId.toString())
          .update({
        'completed': val,
      });
    } catch (e) {
      debugPrint('Error updating vaccine in Firestore: $e');
    }
  }

  Future<void> markVaccinationComplete(
    int vaccineId,
  ) async {
    await setVaccinationCompleted(vaccineId, true);
  }

  Future<void> markReminderSent(
    int vaccineId,
  ) async {
    final db = await database;

    await db.update(
      'vaccinations',
      {
        'reminderSent': 1,
      },
      where: 'id = ?',
      whereArgs: [vaccineId],
    );
  }

  Future<int> getPendingVaccines() async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM vaccinations
      WHERE completed = 0
      ''',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getCompletedVaccines() async {
    final db = await database;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM vaccinations
      WHERE completed = 1
      ''',
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // =========================================================
  // AUTOMATIC INDIAN IMMUNIZATION SCHEDULE
  // =========================================================

  List<Map<String, dynamic>> _generateVaccineSchedule(
    DateTime dob,
  ) {
    final List<Map<String, dynamic>> schedule = [];

    void add(
      String name,
      DateTime date,
    ) {
      schedule.add({
        'name': name,
        'date': date,
      });
    }

    DateTime weeks(int number) {
      return dob.add(
        Duration(days: number * 7),
      );
    }

    DateTime months(int number) {
      return DateTime(
        dob.year,
        dob.month + number,
        dob.day,
      );
    }

    DateTime years(int number) {
      return DateTime(
        dob.year + number,
        dob.month,
        dob.day,
      );
    }

    // ---------------- BIRTH ----------------

    add('BCG', dob);
    add('OPV-0', dob);
    add('Hepatitis B Birth Dose', dob);

    // ---------------- 6 WEEKS ----------------

    add('OPV-1', weeks(6));
    add('Pentavalent-1', weeks(6));
    add('fIPV-1', weeks(6));
    add('Rotavirus-1', weeks(6));
    add('PCV-1', weeks(6));

    // ---------------- 10 WEEKS ----------------

    add('OPV-2', weeks(10));
    add('Pentavalent-2', weeks(10));
    add('Rotavirus-2', weeks(10));

    // ---------------- 14 WEEKS ----------------

    add('OPV-3', weeks(14));
    add('Pentavalent-3', weeks(14));
    add('fIPV-2', weeks(14));
    add('Rotavirus-3', weeks(14));
    add('PCV-2', weeks(14));

    // ---------------- 9 MONTHS ----------------

    add('MR-1', months(9));
    add('PCV Booster', months(9));
    add('fIPV-3', months(9));
    add('Vitamin A - 1st Dose', months(9));

    // ---------------- 16 MONTHS ----------------

    add('MR-2', months(16));
    add('DPT Booster-1', months(16));
    add('OPV Booster', months(16));
    add('Vitamin A - 2nd Dose', months(16));

    // ---------------- VITAMIN A ----------------

    for (int month = 22; month <= 58; month += 6) {
      add(
        'Vitamin A - Follow-up Dose',
        months(month),
      );
    }

    // ---------------- 5 YEARS ----------------

    add(
      'DPT Booster-2',
      years(5),
    );

    // ---------------- 10 YEARS ----------------

    add(
      'Td',
      years(10),
    );

    // ---------------- 16 YEARS ----------------

    add(
      'Td',
      years(16),
    );

    return schedule;
  }
}
