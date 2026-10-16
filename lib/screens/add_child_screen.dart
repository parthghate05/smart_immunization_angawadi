import 'package:flutter/material.dart';
import '../models/child.dart';
import '../database/database_helper.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final motherController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  DateTime? selectedDate;
  String selectedGender = 'Male';

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    motherController.dispose();
    contactController.dispose();
    addressController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> saveChild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
        ),
      );
      return;
    }

    final height = double.tryParse(
      heightController.text.trim(),
    );

    final weight = double.tryParse(
      weightController.text.trim(),
    );

    if (height == null || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid height'),
        ),
      );
      return;
    }

    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final child = Child(
        name: nameController.text.trim(),
        dateOfBirth: selectedDate!,
        gender: selectedGender,
        motherName: motherController.text.trim(),
        contactNumber: contactController.text.trim(),
        address: addressController.text.trim(),
        height: height,
        weight: weight,
      );

      await DatabaseHelper.instance.insertChild(child);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save child: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        title: const Text(
          'Add New Child',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Photo placeholder
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 35,
                    color: Colors.deepPurple,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Child Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _label('Child Name'),

              TextFormField(
                controller: nameController,
                decoration: _inputDecoration(
                  'Enter child name',
                  Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter child name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              _label('Date of Birth'),

              InkWell(
                onTap: selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 17,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        selectedDate == null
                            ? 'Select date of birth'
                            : '${selectedDate!.day}/'
                            '${selectedDate!.month}/'
                            '${selectedDate!.year}',
                        style: TextStyle(
                          color: selectedDate == null
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _label('Gender'),

              Row(
                children: [
                  Expanded(
                    child: _genderButton('Male'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _genderButton('Female'),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // -----------------------------
              // GROWTH INFORMATION
              // -----------------------------

              const Text(
                'Growth Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _label('Height (cm)'),
                        TextFormField(
                          controller: heightController,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _inputDecoration(
                            'e.g. 72',
                            Icons.height,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Required';
                            }

                            final number =
                            double.tryParse(value);

                            if (number == null ||
                                number <= 0) {
                              return 'Invalid';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        _label('Weight (kg)'),
                        TextFormField(
                          controller: weightController,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _inputDecoration(
                            'e.g. 8.5',
                            Icons.monitor_weight_outlined,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Required';
                            }

                            final number =
                            double.tryParse(value);

                            if (number == null ||
                                number <= 0) {
                              return 'Invalid';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              const Text(
                'Parent / Guardian Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              _label("Mother's Name"),

              TextFormField(
                controller: motherController,
                decoration: _inputDecoration(
                  "Enter mother's name",
                  Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return "Please enter mother's name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 18),

              _label('Contact Number'),

              TextFormField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration(
                  'Enter contact number',
                  Icons.phone_outlined,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter contact number';
                  }

                  if (value.length != 10) {
                    return 'Enter a 10-digit contact number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              _label('Address'),

              TextFormField(
                controller: addressController,
                maxLines: 3,
                decoration: _inputDecoration(
                  'Enter address',
                  Icons.location_on_outlined,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveChild,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                    Colors.deepPurple.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'SAVE CHILD',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _genderButton(String gender) {
    final selected = selectedGender == gender;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedGender = gender;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor:
        selected
            ? Colors.deepPurple.shade50
            : Colors.white,
        foregroundColor:
        selected
            ? Colors.deepPurple
            : Colors.black87,
        side: BorderSide(
          color: selected
              ? Colors.deepPurple
              : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(gender),
    );
  }

  InputDecoration _inputDecoration(
      String hint,
      IconData icon,
      ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.deepPurple,
          width: 1.5,
        ),
      ),
    );
  }
}