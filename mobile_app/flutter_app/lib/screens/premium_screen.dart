import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import 'dart:ui';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final worker = ModalRoute.of(context)!.settings.arguments as WorkerModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Insurance Premium')),
      body: Stack(
        children: [
          // Background blobs for glassmorphism effect
          Positioned(
            top: 50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(color: Colors.teal.withOpacity(0.3), shape: BoxShape.circle),
            ),
          ),
          Positioned(
            bottom: 100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.3), shape: BoxShape.circle),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(color: Colors.white.withOpacity(0.5)),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGlassCard(
                  title: 'Total Coverage Amount',
                  amount: '₹${worker.coverage.toStringAsFixed(0)}',
                  icon: Icons.security,
                  color: Colors.teal,
                ),
                const SizedBox(height: 30),
                _buildGlassCard(
                  title: 'Weekly Premium',
                  amount: '₹${worker.premium.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.orange,
                ),
                const SizedBox(height: 50),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false, arguments: worker);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Activate Protection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required String title, required String amount, required IconData icon, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
