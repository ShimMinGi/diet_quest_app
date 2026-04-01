import 'package:flutter/material.dart';

void main() {
  runApp(DietApp());
}

class DietApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DietPage(),
    );
  }
}

class DietPage extends StatefulWidget {
  @override
  _DietPageState createState() => _DietPageState();
}

class _DietPageState extends State<DietPage> {
  TextEditingController weightController = TextEditingController();

  double weight = 0;
  double result = 0;

  void calculate() {
    setState(() {
      weight = double.tryParse(weightController.text) ?? 0;
      result = weight - 1; // 임시 계산
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Diet Quest"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "체중 입력",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: calculate,
              child: Text("계산"),
            ),
            SizedBox(height: 20),
            Text(
              "결과: $result",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}