import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'add_holiday.dart';
import 'add_task.dart';

class SelectType extends StatefulWidget {
  const SelectType({super.key});

  @override
  State<SelectType> createState() => _SelectTypeState();
}

class _SelectTypeState extends State<SelectType> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Select Type')),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AddHoliday()));
              },
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red.shade100,
                ),
                child: Column(
                  children: [
                    Lottie.network(
                        'https://lottie.host/105b1a20-9a55-4163-9770-4c11dc61388b/Q7l3BIxF6t.json',
                        height: 180),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        Text(
                          'Add Holiday',
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20,),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AddTask()));
              },
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.shade100,
                ),
                child: Column(
                  children: [
                    Lottie.network(
                        'https://lottie.host/8cafdc6b-10f3-4c24-9a25-26194b2dc16a/mq5SGsrX1H.json',
                        height: 180),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        Text(
                          'Add Event',
                          style: TextStyle(fontSize: 25),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
