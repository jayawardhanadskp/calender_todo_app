import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../model/event.dart';
import '../notification/notification_service.dart';

class AddTask extends StatefulWidget {
  final Event? event;
  const AddTask({Key? key, this.event}) : super(key: key);

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  // form validation
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final noteController = TextEditingController();
  late DateTime fromDate;
  late DateTime toDate;

  @override
  void initState() {
    super.initState();

    if (widget.event == null) {
      // if user not selected
      fromDate = DateTime.now();
      toDate = DateTime.now().add(const Duration(hours: 1));
    } else {
      // selected data
      fromDate = widget.event!.from;
      toDate = widget.event!.to;
      titleController.text = widget.event!.title;
      noteController.text = widget.event!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        actions: saveEvent(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // title
                TextFormField(
                  style: const TextStyle(fontSize: 24),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Add Title',
                  ),
                  controller: titleController,
                  validator: (title) => title != null && title.isEmpty ? 'Title cannot be empty' : null,
                ),
                const SizedBox(height: 15,),

                // from
                buildDateTimePicker(
                  label: 'From',
                  selectedDate: fromDate,
                  onDateChanged: (date) => setState(() => fromDate = date),
                ),
                const SizedBox(height: 15,),

                // to
                buildDateTimePicker(
                  label: 'To',
                  selectedDate: toDate,
                  onDateChanged: (date) => setState(() => toDate = date),
                ),
                const SizedBox(height: 15,),

                // note
                TextFormField(
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Add Note',
                  ),
                  controller: noteController,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // save event
  List<Widget> saveEvent() => [
    IconButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          saveToFirestore();
        }
      },
      icon: const Icon(Icons.save),
    ),
  ];

  // save data on firestore
  void saveToFirestore() {
    final event = Event(
      title: titleController.text,
      from: fromDate,
      to: toDate,
      description: noteController.text,
    );

    FirebaseFirestore.instance.collection('events').add({
      'title': event.title,
      'from': event.from,
      'to': event.to,
      'note': event.description
    }).then((value) {
      scheduleNotificationsForEvent(event);
      Navigator.of(context).pop();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add event: $error')),
      );
    });
  }

  void scheduleNotificationsForEvent(Event event) {
    DateTime eventTime = event.to;

    // Schedule notifications for 15 mins, 1 hour, and 1 day before the event's end time
    scheduleNotification(eventTime.subtract(Duration(minutes: 15)), event.title, event.description ?? '');
    scheduleNotification(eventTime.subtract(Duration(hours: 1)), event.title, event.description ?? '');
    scheduleNotification(eventTime.subtract(Duration(days: 1)), event.title, event.description ?? '');
  }

  // date time picker
  Widget buildDateTimePicker({
    required String label,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: buildDropdownField(
                text: DateFormat.yMd().format(selectedDate),
                onClicked: () => pickDateTime(context, selectedDate, onDateChanged, true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: buildDropdownField(
                text: DateFormat.Hm().format(selectedDate),
                onClicked: () => pickDateTime(context, selectedDate, onDateChanged, false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDropdownField({
    required String text,
    required VoidCallback onClicked,
  }) {
    return ListTile(
      title: Text(text),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: onClicked,
    );
  }

  // get date & time
  Future<void> pickDateTime(
      BuildContext context,
      DateTime initialDate,
      ValueChanged<DateTime> onDateChanged,
      bool isDate
      ) async {
    if (isDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (date != null) {
        final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);
        final newDate = date.add(time);

        // show snakbar message incorrect date selection
        if (newDate.isBefore(fromDate)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End date cannot be before start date')),
          );
        } else {
          onDateChanged(newDate);
        }
      }
    } else {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (time != null) {
        final newDate = DateTime(initialDate.year, initialDate.month, initialDate.day, time.hour, time.minute);
        if (initialDate.year == fromDate.year &&
            initialDate.month == fromDate.month &&
            initialDate.day == fromDate.day &&
            newDate.isBefore(fromDate)) {
          // show snakbar message incorrect time selection
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End time cannot be before start time')),
          );
        } else {
          onDateChanged(newDate);
        }
      }
    }
  }
}
