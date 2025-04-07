import 'package:flutter/material.dart';
import 'package:ridesafe/screens/login_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/motorcycle.png',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.5), // Add overlay to make text more readable
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Content
          SafeArea(
            child: Center( // Added Center widget
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Changed to center
                  crossAxisAlignment: CrossAxisAlignment.center, // Added for horizontal centering
                  children: [
                    const Text(
                      'RIDE SAFE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // Added for text centering
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ride Smart, Stay Safe!',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center, // Added for text centering
                    ),
                    const SizedBox(height: 50),
                    SizedBox( // Added SizedBox for button width
                      width: 200, // You can adjust this value
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Remove FirebaseTest() widget from here
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}