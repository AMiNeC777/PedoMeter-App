import 'package:flutter/material.dart';

class StepCounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace with actual step count logic
    int steps = 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Steps', style: TextStyle(fontSize: 24)),
            SizedBox(height: 10),
            Text('$steps', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
