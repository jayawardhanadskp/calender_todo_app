import 'package:flutter/material.dart';
import '../widgets/select_type.dart';
import 'calendar_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Event App'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade100,
      ),


      body: const CalendarScreen(), // calendar

      // add event button
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.event),
        onPressed: () {
          // navigate to add event
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => const SelectType()));
        },
      ),
    );
  }
}
