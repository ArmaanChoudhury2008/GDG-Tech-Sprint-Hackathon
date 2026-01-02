import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import the courier
import 'dart:convert'; // Import the tool to translate JSON

void main() {
  runApp(const MaterialApp(home: MessPredictionScreen()));
}

class MessPredictionScreen extends StatefulWidget {
  const MessPredictionScreen({super.key});

  @override
  State<MessPredictionScreen> createState() => _MessPredictionScreenState();
}

class _MessPredictionScreenState extends State<MessPredictionScreen> {
  // Controllers to get text from the user
  final TextEditingController _pollController = TextEditingController();
  
  // Variables to store the state
  bool _isRainy = false;
  String _result = "Enter data to get prediction";
  bool _isLoading = false;

  // --- THE CORE FUNCTION ---
  Future<void> getPrediction() async {
    // 1. Validate input
    if (_pollController.text.isEmpty) return;

    setState(() {
      _isLoading = true; // Show a loading spinner
      _result = "Asking the AI...";
    });

    // 2. Prepare the URL and Data
    // REPLACE THIS URL with your actual Render URL!
    final url = Uri.parse('https://techsprint-ai.onrender.com');
    
    final bodyData = jsonEncode({
      'poll_count': int.parse(_pollController.text), // Convert text to number
      'is_rainy': _isRainy
    });

    try {
      // 3. Send the POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: bodyData,
      );

      // 4. Handle the Response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // Convert JSON back to Dart
        final qty = data['predicted_quantity'];
        
        setState(() {
          _result = "Cook for: $qty Students";
        });
      } else {
        setState(() {
          _result = "Error: Server returned ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Failed to connect. Check internet.";
      });
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false; // Hide spinner
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mess AI Manager")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Input 1: Poll Count
            TextField(
              controller: _pollController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Total Student Polls",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Input 2: Weather Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Is it Raining today?", style: TextStyle(fontSize: 18)),
                Switch(
                  value: _isRainy,
                  onChanged: (val) {
                    setState(() {
                      _isRainy = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : getPrediction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("PREDICT QUANTITY", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 40),

            // Result Display
            Text(
              _result,
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: Colors.green
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
