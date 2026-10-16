class Child {
  int? id;

  String name;
  DateTime dateOfBirth;
  String gender;
  String motherName;
  String contactNumber;
  String address;

  double height;
  double weight;

  Child({
    this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.motherName,
    required this.contactNumber,
    required this.address,
    required this.height,
    required this.weight,
  });

  int get ageInMonths {
    final now = DateTime.now();

    int months =
        (now.year - dateOfBirth.year) * 12 +
            now.month -
            dateOfBirth.month;

    if (now.day < dateOfBirth.day) {
      months--;
    }

    return months < 0 ? 0 : months;
  }

  String get ageText {
    final months = ageInMonths;

    if (months < 12) {
      return '$months months';
    }

    final years = months ~/ 12;
    final remainingMonths = months % 12;

    if (remainingMonths == 0) {
      return years == 1 ? '1 year' : '$years years';
    }

    return '$years year $remainingMonths months';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'motherName': motherName,

      'contactNumber': contactNumber,
      'address': address,
      'height': height,
      'weight': weight,
    };
  }

  factory Child.fromMap(Map<String, dynamic> map) {
    return Child(
      id: map['id'],
      name: map['name'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      gender: map['gender'],
      motherName: map['motherName'],
      contactNumber: map['contactNumber'],
      address: map['address'],
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
    );
  }
}