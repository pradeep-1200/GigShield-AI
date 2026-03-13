import 'dart:async';
import 'package:flutter/material.dart';
import '../models/worker_model.dart';
import '../services/api_service.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> with SingleTickerProviderStateMixin {
  late WorkerModel worker;
  Map<String, dynamic>? _weatherData;
  bool _isDisrupted = false;
  bool _forceSevereOverride = false;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_pulseController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    worker = ModalRoute.of(context)!.settings.arguments as WorkerModel;
    _startLiveMonitoring();
  }

  void _startLiveMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!_isDisrupted) {
        _fetchWeather();
      }
    });
    _fetchWeather();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    try {
      final data = await ApiService.monitorWeather(worker.city, forceDemo: _forceSevereOverride);
      if (mounted) {
        setState(() {
          _weatherData = data;
        });
        _checkTriggers(data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _checkTriggers(Map<String, dynamic> weather) {
    double rain = (weather['rainfall'] as num).toDouble();
    double temp = (weather['temperature'] as num).toDouble();
    double aqi = (weather['aqi'] as num).toDouble();

    if (rain > 50 || temp > 42 || aqi > 350) {
      setState(() => _isDisrupted = true);
      _triggerClaim(rain, temp, aqi);
    }
  }

  Future<void> _triggerClaim(double rain, double temp, double aqi) async {
    try {
      final data = await ApiService.triggerClaim({
        'rainfall': rain,
        'temperature': temp,
        'aqi': aqi,
        'weekly_income': worker.weeklyIncome,
        'working_hours': worker.workingHours,
        'hours_lost': 4
      });

      if (data['status'] == 'triggered') {
        _timer?.cancel();
        
        // Show push notification simulation popup before redirecting
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠ Severe Event Detected! Insurance Claim Initiated.'), 
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(20),
            ),
          );
        }

        await Future.delayed(const Duration(seconds: 3));

        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context, 
          '/payout',
          arguments: {
            'worker': worker,
            'claimData': data,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color getGaugeColor(String key, double val) {
    if (key == 'rain') {
      if (val < 10) return Colors.green;
      if (val < 50) return Colors.orange;
      return Colors.red;
    }
    if (key == 'temp') {
      if (val < 35) return Colors.green;
      if (val < 42) return Colors.orange;
      return Colors.red;
    }
    if (key == 'aqi') {
      if (val < 150) return Colors.green;
      if (val < 350) return Colors.orange;
      return Colors.red;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Weather Radar')),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isDisrupted ? Colors.red.shade50 : Colors.teal.shade50,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isDisrupted ? Colors.red.withOpacity(0.3) : Colors.teal.withOpacity(0.3),
                          border: Border.all(
                            color: _isDisrupted ? Colors.red : Colors.teal,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _isDisrupted ? Icons.warning_amber_rounded : Icons.radar,
                          size: 80,
                          color: _isDisrupted ? Colors.red : Colors.teal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _isDisrupted ? '⚠ Extreme Danger Threshold Exceeded!' : 'Monitoring environmental gauges for ${worker.city}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isDisrupted ? Colors.red : Colors.teal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    if (_weatherData == null)
                      const CircularProgressIndicator()
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildGauge(
                              'Rainfall', 
                              '${_weatherData!['rainfall']} mm', 
                              Icons.water_drop, 
                              getGaugeColor('rain', (_weatherData!['rainfall'] as num).toDouble())
                            ),
                            _buildGauge(
                              'Temperature', 
                              '${_weatherData!['temperature']} °C', 
                              Icons.thermostat, 
                              getGaugeColor('temp', (_weatherData!['temperature'] as num).toDouble())
                            ),
                            _buildGauge(
                              'Air Quality (AQI)', 
                              '${_weatherData!['aqi']}', 
                              Icons.air, 
                              getGaugeColor('aqi', (_weatherData!['aqi'] as num).toDouble())
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: SwitchListTile(
                  title: const Text('Force Override (Demo)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Injects severe simulated weather'),
                  activeColor: Colors.red,
                  value: _forceSevereOverride,
                  onChanged: (bool value) {
                    setState(() {
                      _forceSevereOverride = value;
                    });
                    if (!_isDisrupted) _fetchWeather();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(String label, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}
