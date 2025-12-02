import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedo_metreapp/screens/home_screen.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 23, 23, 40),
      body: SafeArea(
        child: Padding(
          // Use symmetric padding for consistent horizontal spacing
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Stack(
            children: [
              Positioned(
                top: 50,
                right: 0,
                left: 20,
                child: Container(
                  height: 600,
                  child: Image.asset(
                  "assets/images/Background.png",
                              // Adjust height as needed for your asset
                              height: 700,
                              width: 700,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                  // Friendly fallback if the image is missing
                  return Container(
                    height: 300,
                    width: 250,
                    color: Colors.white.withOpacity(0.1),
                    child: const Center(
                      child: Text(
                        'Add "BG3.png" to assets/images/',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  );
                              },
                            ),
                ),
              ),
              Column(
              // This structure divides the screen into 3 parts:
              // Header (top), Middle (runner/text), Footer (button)
              children: [
                _buildHeader(),
                const Spacer(flex: 1), // Pushes content apart
                _buildMiddleContent(),
                const Spacer(flex: 2), // More space below middle content
                _buildFooter(context),
                const SizedBox(height: 16), // Bottom padding
              ],
            ),
          ]),
        ),
      ),
    );
  }

  // --- HEADER WIDGET ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Note: The icons in the image are custom.
              // We're using standard Material icons as placeholders.
              const Icon(Icons.wifi, color: Colors.white, size: 40),
              const SizedBox(width: 12),
              Text(
                "CIRCUIT RUN",
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              // Using 'developer_board' as a stand-in for the CPU icon
              const Icon(Icons.developer_board, color: Colors.white, size: 40),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "DATA MEETS MOTION",
            style: GoogleFonts.lato(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  // --- MIDDLE CONTENT WIDGET ---
  Widget _buildMiddleContent() {
    return Column(
      children: [
        SizedBox(height: 380),
        const SizedBox(height: 24),
        Text(
          "UNLOCK YOUR POTENTIAL",
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900, // Extra-bold
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Powered by Raspberry Pi & Accelerometer",
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            color: Colors.white60,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // --- FOOTER WIDGET ---
  Widget _buildFooter(context) {
    return Column(
      children: [
        // --- GRADIENT BUTTON ---
        Container(
          decoration: BoxDecoration(
            // The Cyan-to-Pink gradient
            gradient: const LinearGradient(
              colors: [Color(0xFF00FFFF), Color(0xFFFF4081)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: ElevatedButton(
            onPressed: () {
              // Navigate to the next screen
              Navigator.push(context , MaterialPageRoute(builder: (context) => HomeScreen('ghofrane')));
            },
            style: ElevatedButton.styleFrom(
              // Make the button transparent to show the container's gradient
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "START YOUR JOURNEY",
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
 
      ],
    );
  }
}