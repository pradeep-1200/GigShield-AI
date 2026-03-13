import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/worker_model.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final worker = ModalRoute.of(context)!.settings.arguments as WorkerModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Hub'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hello ${worker.name.split(' ')[0]} 👋', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const Text('Your Protection Status:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_user, color: Colors.green, size: 20),
                        SizedBox(width: 5),
                        Text('ACTIVE', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              
              FutureBuilder<bool>(
                future: ApiService.checkHealth(),
                builder: (context, snapshot) {
                  final isConnected = snapshot.connectionState == ConnectionState.waiting 
                      ? false 
                      : (snapshot.data ?? false);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isConnected ? Colors.green : Colors.red),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isConnected ? Icons.cloud_done : Icons.cloud_off, color: isConnected ? Colors.green : Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Backend Status: ${isConnected ? "Connected" : "Offline"}',
                          style: TextStyle(color: isConnected ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Hero Cards horizontal scroll
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildHeroCard('Risk Score', worker.riskScore.toStringAsFixed(2), Icons.analytics, Colors.orange),
                    _buildHeroCard('Weekly Premium', '₹${worker.premium.toStringAsFixed(2)}', Icons.payment, Colors.purple),
                    _buildHeroCard('Coverage', '₹${worker.coverage.toStringAsFixed(0)}', Icons.security, Colors.teal),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // Policy Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.teal, Color(0xFF00695C)]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active Insurance Policy', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 5),
                    Text(worker.policyId, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Platform', style: TextStyle(color: Colors.white70)),
                            Text(worker.platform, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Valid From', style: TextStyle(color: Colors.white70)),
                            Text(worker.activationDate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),
              
              const Text('Risk Trend (Last 7 Days)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 20),
              
              // Animated Line Chart Mock
              Container(
                height: 200,
                padding: const EdgeInsets.only(right: 20, top: 20, bottom: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 0.2),
                          FlSpot(1, 0.35),
                          FlSpot(2, 0.4),
                          FlSpot(3, 0.5),
                          FlSpot(4, 0.45),
                          FlSpot(5, 0.6),
                          FlSpot(6, 0.55),
                        ],
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: true, color: Colors.orange.withOpacity(0.2)),
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/monitor', arguments: worker),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal,
                        side: BorderSide(color: Colors.teal.shade200, width: 2),
                      ),
                      icon: const Icon(Icons.radar),
                      label: const Text('Weather Radar'),
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

  Widget _buildHeroCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Container(
             padding: const EdgeInsets.all(8),
             decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
             child: Icon(icon, color: color, size: 28),
           ),
           const SizedBox(height: 15),
           Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
           const SizedBox(height: 5),
           Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
