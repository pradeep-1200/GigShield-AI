import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../models/worker_model.dart';
import '../services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController(text: 'John Doe');
  final _cityController = TextEditingController(text: '');
  final _incomeController = TextEditingController(text: '5000');
  final _hoursController = TextEditingController(text: '8');
  final _platformController = TextEditingController(text: 'Zomato');

  bool _isLoading = false;
  bool _isLocating = false;

  void _getLiveLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        String city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? 'Chennai';
        setState(() {
          _cityController.text = city;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location detected: $city'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch GPS. Trying manual entry.'), backgroundColor: Colors.orange),
        );
      }
    } finally {
      setState(() => _isLocating = false);
    }
  }

  void _calculateRisk() async {
    if (_cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a city'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      WorkerModel worker = WorkerModel(
        name: _nameController.text,
        city: _cityController.text,
        weeklyIncome: int.tryParse(_incomeController.text) ?? 5000,
        workingHours: int.tryParse(_hoursController.text) ?? 8,
        platform: _platformController.text,
      );

      Map<String, dynamic> result = await ApiService.predictRisk({
        'city': worker.city,
        'income': worker.weeklyIncome,
        'hours': worker.workingHours,
        'platform': worker.platform,
      });

      worker.riskScore = result['risk_score'].toDouble();
      worker.weatherData = result['weather_data'];
      worker.aiExplanation = result['ai_explanation'];

      if (!mounted) return;
      Navigator.pushNamed(
        context, 
        '/risk',
        arguments: worker,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GigShield AI')),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Protect Your Earnings',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              Text(
                'Register below to calculate your customized insurance risk score.',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),
              _buildTextField(_nameController, 'Name', Icons.person),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(
                     child: _buildTextField(_cityController, 'City', Icons.location_city),
                   ),
                   const SizedBox(width: 10),
                   _isLocating 
                    ? const CircularProgressIndicator() 
                    : IconButton(
                      icon: const Icon(Icons.gps_fixed, color: Colors.teal, size: 30),
                      onPressed: _getLiveLocation,
                      tooltip: 'Auto-detect location',
                    )
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_incomeController, 'Weekly Income (₹)', Icons.currency_rupee, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_hoursController, 'Working Hours / Day', Icons.access_time, isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_platformController, 'Platform (Swiggy, Zomato)', Icons.delivery_dining),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Fetching Weather Data & Analysing AI Risk...', style: TextStyle(color: Colors.teal))
                      ]
                    ))
                  : ElevatedButton.icon(
                      onPressed: _calculateRisk,
                      icon: const Icon(Icons.analytics),
                      label: const Text('Calculate Risk Score'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
      ),
    );
  }
}
