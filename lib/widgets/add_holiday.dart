import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/event.dart';

class AddHoliday extends StatefulWidget {
  const AddHoliday({Key? key});

  @override
  State<AddHoliday> createState() => _AddHolidayState();
}

class _AddHolidayState extends State<AddHoliday> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  DateTime? selectedDate;

  // function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select Date'))
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // save data
  void saveToFirestore() {
    if (_formKey.currentState!.validate()) {
      final holiday = Holiday(
        title: nameController.text,
        date: selectedDate!,
      );
      FirebaseFirestore.instance.collection('holidays').add({
        'title': holiday.title,
        'date': holiday.date,
      }).then((value){
        Navigator.of(context).pop();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Holiday'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Holiday name
                TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Holiday Name',
                  ),
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a holiday name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Date picker
                TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Select Date',
                  ),
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Select Date';
                    }
                    return null;
                  },
                  controller: TextEditingController(
                    text: selectedDate == null
                        ? ''
                        : DateFormat('yyyy-MM-dd').format(selectedDate!),
                  ),
                ),
                const SizedBox(height: 15,),

                // save button
                ElevatedButton(
                    onPressed: () {
                      saveToFirestore();
                    },
                    child: const Text('Save'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
