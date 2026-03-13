import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/worker_model.dart';
import '../services/api_service.dart';
import 'dart:math';

class RiskScreen extends StatefulWidget {
  const RiskScreen({super.key});

  @override
  State<RiskScreen> createState() => _RiskScreenState();
}

class _RiskScreenState extends State<RiskScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getRiskLevel(double score) {
    if (score < 0.3) return "Low Risk";
    if (score < 0.6) return "Moderate Risk";
    return "High Danger Risk";
  }

  Color getRiskColor(double score) {
    if (score < 0.3) return Colors.green;
    if (score < 0.6) return Colors.orange;
    return Colors.red;
  }

  void _calculatePremium(WorkerModel worker) async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> data = await ApiService.calculatePremium({
        'risk': worker.riskScore,
        'income': worker.weeklyIncome,
      });

      worker.coverage = (data['coverage'] as num).toDouble();
      worker.premium = (data['premium'] as num).toDouble();

      if (!mounted) return;
      Navigator.pushNamed(
        context, 
        '/premium',
        arguments: worker,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final worker = ModalRoute.of(context)!.settings.arguments as WorkerModel;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Risk Analysis')),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, getRiskColor(worker.riskScore).withOpacity(0.05)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text('Live Risk Score for ${worker.city}', style: const TextStyle(fontSize: 20, color: Colors.grey)),
              const SizedBox(height: 30),
              
              // Animated Circular Gauge
              SizedBox(
                height: 200,
                width: 200,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: RiskGaugePainter(_animation.value * worker.riskScore, getRiskColor(worker.riskScore)),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (_animation.value * worker.riskScore).toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: getRiskColor(worker.riskScore),
                              ),
                            ),
                            Text(
                              getRiskLevel(worker.riskScore),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: getRiskColor(worker.riskScore),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
              // AI Explanation Card
              if (worker.aiExplanation != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text('AI Explanation', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(worker.aiExplanation!, style: const TextStyle(fontSize: 16, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: _isLoading
                    ? const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Generating Premium Plan...', style: TextStyle(color: Colors.teal))
                        ]
                      )
                    : ElevatedButton(
                        onPressed: () => _calculatePremium(worker),
                        child: const Text('Get Premium Quote'),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class RiskGaugePainter extends CustomPainter {
  final double score;
  final Color color;

  RiskGaugePainter(this.score, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint trackPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..color = color
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5,
      false,
      trackPaint,
    );

    double sweepAngle = (score) * pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
