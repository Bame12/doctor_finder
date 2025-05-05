import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:doctor_finder_flutter/firebase_options.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String status = 'Testing Firebase...';

  @override
  void initState() {
    super.initState();
    testFirebase();
  }

  Future<void> testFirebase() async {
    try {
      setState(() {
        status = 'Checking if Firebase is already initialized...';
      });

      if (Firebase.apps.isEmpty) {
        setState(() {
          status = 'Firebase apps is empty. Initializing...';
        });

        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        setState(() {
          status = 'Firebase initialized successfully!';
        });
      } else {
        setState(() {
          status = 'Firebase already initialized. App count: ${Firebase.apps.length}';
        });
      }

      // Additional checks
      final app = Firebase.app();
      setState(() {
        status += '\nApp name: ${app.name}';
        status += '\nProject ID: ${app.options.projectId}';
        status += '\nAPI Key: ${app.options.apiKey}';
        status += '\nApp ID: ${app.options.appId}';
      });

    } catch (e, stackTrace) {
      setState(() {
        status = 'Error: $e\n\nStack trace:\n$stackTrace';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: testFirebase,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}