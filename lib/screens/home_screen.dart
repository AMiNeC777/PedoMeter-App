import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedo_metreapp/widgets/statcard.dart';
import 'package:pedo_metreapp/screens/ble_pedometer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(this.name, {super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Row(
          children: [
            Text(
              'PedoMetre',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.directions_run,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BLEPedometerScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.bluetooth,
              color: Colors.white,
              size: 28,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Text
            Text(
              'Good work for today, $name''🔥',
              style: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),

            // Main Headline
            Text(
              'Run Your Way to Better Health',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            _buildStatsRow(),
            const SizedBox(height: 20),

            // Distance Card
            _buildDistanceCard(),
            const SizedBox(height: 20),

            // Calories Burnt Card
            _buildCaloriesCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Stack(
      children: 
      [
      Container(
        padding: const EdgeInsets.all(20),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF5CACEB), // Blue
              Color(0xFF4CAF50), // Green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.directions_walk,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Daily Steps',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '8,451',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 52,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'steps',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Increase 5.4%',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.info_outline,
                      color: Colors.white.withOpacity(0.9),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
            
          ],
        ),
      ),
      Positioned(
              right: -25,
              bottom: 0,
              child: SizedBox(
                height: 220,
                width: 200,
                child: Image.asset(
                  'assets/images/runner.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildDistanceCard() {
    return const Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.directions_run,
            iconColor: Color(0xFFEF6C00), // Deep Orange
            label: 'Your Distance',
            value: '10.24',
            unit: 'km',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            icon: Icons.favorite_border,
            iconColor: Color(0xFF4CAF50), // Green
            label: 'Heart Rate',
            value: '124',
            unit: 'bpm',
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark card background
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange[600]),
              const SizedBox(width: 8),
              Text(
                'Calories Burnt',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '580',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kcal',
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final Color barColor = const Color.fromARGB(255, 99, 114, 141);
    final Color highlightedBarColor = const Color.fromARGB(255, 177, 149, 219);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 12, // Max value on Y-axis (for relative height)
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                String text;
                switch (value.toInt()) {
                  case 0:
                    text = 'Sun';
                    break;
                  case 1:
                    text = 'Mon';
                    break;
                  case 2:
                    text = 'Tue';
                    break;
                  case 3:
                    text = 'Wed';
                    break;
                  case 4:
                    text = 'Thu';
                    break;
                  case 5:
                    text = 'Fri';
                    break;
                  case 6:
                    text = 'Sat';
                    break;
                  default:
                    text = '';
                    break;
                }
                return Text(
                  text,
                  style: GoogleFonts.poppins(
                      color: Colors.grey[500], fontSize: 12),
                );
              },
              reservedSize: 30,
            ),
          ),
        ),
        barGroups: [
          _buildBarGroupData(0, 8, color: barColor),
          _buildBarGroupData(1, 7, color: barColor),
          _buildBarGroupData(2, 10, color: highlightedBarColor), // Tuesday
          _buildBarGroupData(3, 6, color: barColor),
          _buildBarGroupData(4, 5, color: barColor),
          _buildBarGroupData(5, 7.5, color: barColor),
          _buildBarGroupData(6, 6.5, color: barColor),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroupData(int x, double y,
      {required Color color}) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
      ],
    );
  }
}

