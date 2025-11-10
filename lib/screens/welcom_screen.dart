import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedo_metreapp/screens/home_screen.dart';
import 'package:pedo_metreapp/screens/stats_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _name = '';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _name = _nameController.text;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'STEP INTO STRENGTH',
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(181, 255, 255, 255),
                  height: 1,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'TURN YOUR STEPS\nINTO MILESTONES ',
                style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                height: 0.9
                ),
              ),
              const SizedBox(height: 40),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.asset(
                      'assets/images/pedometer.png',
                      height: 610,
                      width: 600,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Spacer(),
                  Positioned(
                    bottom: 40,
                    left: 20, // Add left padding
                    right: 20, // Add right padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, // Make children stretch
                      children: [
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(
                              color:
                                  Color.fromARGB(255, 255, 255, 255)),
                          decoration: InputDecoration(
                            hintText: 'Enter your name',
                            hintStyle:
                                const TextStyle(color: Colors.white54),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.white38),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 60, // Reduced height
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      if (_name.trim().isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter your name')),
                                        );
                                        return;
                                      }

                                      FocusScope.of(context).unfocus();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Welcome, $_name!')),
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomeScreen(_name),
                                        ),
                                      );
                                    },
                                    child: const Center(
                                      child: Text(
                                        'GET STARTED',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}