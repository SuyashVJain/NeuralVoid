// lib/features/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();
  String selectedClass = "Class 10";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome to NeuralLearn",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Name Input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Student Name",
              ),
            ),

            const SizedBox(height: 20),

            // Class Dropdown
            DropdownButtonFormField<String>(
              value: selectedClass,
              decoration: const InputDecoration(
                labelText: "Select Class",
              ),
              items: const [
                DropdownMenuItem(
                  value: "Class 10",
                  child: Text("Class 10"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedClass = value!;
                });
              },
            ),

            const SizedBox(height: 40),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // For now just print
                  print("Name: ${_nameController.text}");
                },
                child: const Text("Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}