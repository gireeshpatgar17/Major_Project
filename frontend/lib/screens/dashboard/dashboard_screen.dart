import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../widgets/sensor_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? sensorData;
  bool isLoading = true;
  String? errorMessage;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();

    loadSensorData();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => loadSensorData(),
    );
  }

  Future<void> loadSensorData() async {
    try {
      final data = await ApiService.getSensorData();

      if (!mounted) return;

      setState(() {
        sensorData = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load sensor data';
      });
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Agriculture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadSensorData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: loadSensorData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : buildDashboard(),
    );
  }

  Widget buildDashboard() {
    final temperature = sensorData?['temperature'];
    final humidity = sensorData?['humidity'];
    final soilMoisture = sensorData?['soil_moisture'];
    final waterStatus = sensorData?['water_status'];
    final pumpStatus = sensorData?['pump_status'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farm Dashboard',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            'Monitor your farm in real time',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: SensorCard(
                  title: 'Temperature',
                  value: '${temperature ?? '--'}°C',
                  icon: Icons.thermostat,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: SensorCard(
                  title: 'Humidity',
                  value: '${humidity ?? '--'}%',
                  icon: Icons.water,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SensorCard(
                  title: 'Soil Moisture',
                  value: '${soilMoisture ?? '--'}%',
                  icon: Icons.grass,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: SensorCard(
                  title: 'Water',
                  value: waterStatus ?? '--',
                  icon: Icons.water_drop,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, size: 40, color: Colors.blue),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Irrigation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text('Pump is currently ${pumpStatus ?? '--'}'),
                      ],
                    ),
                  ),

                  Switch(value: pumpStatus == 'ON', onChanged: null),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.eco)),

              title: const Text(
                'Crop Health',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: const Text('AI analysis available in AI section'),

              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
