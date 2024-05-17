
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../notification/notification_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // hold appointments
  List<Appointment> _appointments = [];

  // hold events categorized by date
  Map<DateTime, List<Appointment>> _eventsMap = {};

  @override
  void initState() {
    super.initState();
    fetchHolidays();
    fetchEvents();
  }

  // fetch holidays
  void fetchHolidays() {
    FirebaseFirestore.instance.collection('holidays').snapshots().listen((snapshot) {
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime holidayDate = (data['date'] as Timestamp).toDate();
        Appointment holiday = Appointment(
          startTime: holidayDate,
          endTime: holidayDate,
          subject: 'Holiday',
          color: Colors.red,
        );
        setState(() {
          _appointments.add(holiday);
          DateTime eventDate = DateTime(holidayDate.year, holidayDate.month, holidayDate.day);
          if (!_eventsMap.containsKey(eventDate)) {
            _eventsMap[eventDate] = [];
          }
          _eventsMap[eventDate]!.add(holiday);
        });
      });
    });
  }

  // fetch events
  void fetchEvents() {
    FirebaseFirestore.instance.collection('events').snapshots().listen((snapshot) {
      List<Appointment> appointments = [];
      Map<DateTime, List<Appointment>> eventsMap = {};

      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime fromDate = (data['from'] as Timestamp).toDate();
        DateTime toDate = (data['to'] as Timestamp).toDate();
        DateTime eventDate = DateTime(fromDate.year, fromDate.month, fromDate.day);

        if (!eventsMap.containsKey(eventDate)) {
          eventsMap[eventDate] = [];
        }

        // create appointment
        final appointment = Appointment(
          startTime: fromDate,
          endTime: toDate,
          subject: data['title'],
          notes: data['note'],
          color: Colors.blue,
        );
        eventsMap[eventDate]!.add(appointment);
        appointments.add(appointment);
        scheduleNotificationsForEvent(appointment);
      });

      setState(() {
        _eventsMap = eventsMap;
        _appointments.addAll(appointments);
      });
    });
  }

  // schedule notifications
  void scheduleNotificationsForEvent(Appointment appointment) {
    DateTime toDate = appointment.startTime;

    scheduleNotification(
      toDate.subtract(const Duration(minutes: 15)),
      appointment.subject,
      appointment.notes ?? '',
    );
    scheduleNotification(
      toDate.subtract(const Duration(hours: 1)),
      appointment.subject,
      appointment.notes ?? '',
    );
    scheduleNotification(
      toDate.subtract(const Duration(days: 1)),
      appointment.subject,
      appointment.notes ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: SfCalendar(
        view: CalendarView.month,
        initialSelectedDate: DateTime.now(),
        dataSource: EventDataSource(_appointments),
        monthCellBuilder: monthCellBuilder,
        onTap: calendarTapped,
      ),
    );
  }

  // month cells
  Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
    final DateTime date = details.date;
    final bool hasEvent = _eventsMap.containsKey(DateTime(date.year, date.month, date.day));
    final bool isHoliday = _appointments.any((appointment) =>
    appointment.startTime.year == date.year &&
        appointment.startTime.month == date.month &&
        appointment.startTime.day == date.day &&
        appointment.subject == 'Holiday');

    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            DateFormat.d().format(date),
            style: TextStyle(
              color:  isHoliday ? Colors.red : hasEvent ? Colors.green :Colors.black,
              fontWeight: hasEvent || isHoliday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (hasEvent)
          const Positioned(
            bottom: 4,
            right: 4,
            child: Icon(
              Icons.circle,
              color: Colors.green,
              size: 8,
            ),
          ),
        if (isHoliday)
          const Positioned(
              bottom: 4,
              right: 4,
              child: Icon(Icons.circle, color: Colors.red,size: 8,))
      ],
    );
  }

  // calendar cell tap
  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      DateTime selectedDate = details.date!;
      // Fetch events for selected date
      List<Appointment>? events = _eventsMap[DateTime(selectedDate.year, selectedDate.month, selectedDate.day)];
      if (events != null && events.isNotEmpty) {
        showModalBottomSheet(
          context: context,
          builder: (context) => buildBottomSheet(events),
        );
      }
    }
  }

  // bottom sheet
  Widget buildBottomSheet(List<Appointment> events) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          Appointment event = events[index];
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Event Title', style: TextStyle(fontSize: 20, color: Colors.black45)),
                  const SizedBox(width: 10),
                  Text(event.subject, style: const TextStyle(fontSize: 28)),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('From', style: TextStyle(fontSize: 20, color: Colors.black45)),
                Text('${DateFormat.yMMMd().format(event.startTime)} - ${DateFormat.Hm().format(event.startTime)}', style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 10),
                const Text('To', style: TextStyle(fontSize: 20, color: Colors.black45)),
                Text('${DateFormat.yMMMd().format(event.endTime)} - ${DateFormat.Hm().format(event.endTime)}', style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 10),
                const Text('Notes', style: TextStyle(fontSize: 20, color: Colors.black45)),
                if (event.notes != null && event.notes!.isNotEmpty)
                  ...[
                    const SizedBox(height: 5),
                    Text(event.notes!, style: const TextStyle(fontSize: 28)),
                  ],
                const SizedBox(height: 10,),
                const Divider(thickness: 2,)
              ],
            ),
          );
        },
      ),
    );
  }
}

// for calendar
class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Appointment> source) {
    appointments = source;
  }
}
