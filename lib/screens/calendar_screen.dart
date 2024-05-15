import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import '../model/event.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // hoald the appoinments
  List<Appointment> _appointments = [];

  // hold the events categorized by date
  Map<DateTime, List<Appointment>> _eventsMap = {};

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  // fetch events from firestore
  Stream<List<Appointment>> fetchEvents() {
    return FirebaseFirestore.instance.collection('events').snapshots().map((snapshot) {
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
      });


      _eventsMap = eventsMap;
      return appointments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: StreamBuilder<List<Appointment>>(

        stream: fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // fetched data
            _appointments = snapshot.data!;
            return SfCalendar(
              view: CalendarView.month,
              initialSelectedDate: DateTime.now(),
              dataSource: EventDataSource(_appointments),
              monthCellBuilder: monthCellBuilder,
              onTap: calendarTapped,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error fetching events: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  // month cells
  Widget monthCellBuilder(BuildContext context, MonthCellDetails details) {
    final DateTime date = details.date;
    final bool hasEvent = _eventsMap.containsKey(DateTime(date.year, date.month, date.day));

    return Stack(
      children: [
        Container(
          alignment: Alignment.center,
          child: Text(
            DateFormat.d().format(date),
            style: TextStyle(
              color: hasEvent ? Colors.red : Colors.black,
              fontWeight: hasEvent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (hasEvent)
          const Positioned(
            bottom: 4,
            right: 4,
            child: Icon(
              Icons.circle,
              color: Colors.red,
              size: 8,
            ),
          ),
      ],
    );
  }

  // calendar cell tap
  void calendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.calendarCell) {
      DateTime selectedDate = details.date!;
      // fetch events for selected date
      List<Appointment>? events = _eventsMap[DateTime(selectedDate.year, selectedDate.month, selectedDate.day)];
      if (events != null && events.isNotEmpty) {
        showModalBottomSheet(
          context: context,
          builder: (context) => buildBottomSheet(events),
        );
      }
    }
  }

  //bottom sheet
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
