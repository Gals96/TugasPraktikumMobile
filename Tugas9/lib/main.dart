import 'package:flutter/material.dart';
import 'hewan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Hewan hewan = Hewan("Hewan A", 4.5);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Latihan 2"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                "Berat: ${hewan.berat.toStringAsFixed(2)} kg",
                style: const TextStyle(fontSize: 24),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hewan.berat += 1;  
                  });
                },
                child: const Text("Makan (+1 kg)"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    hewan.berat -= 0.5;
                    if (hewan.berat < 0) hewan.berat = 0;
                  });
                },
                child: const Text("Lari (-0.5 kg)"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
