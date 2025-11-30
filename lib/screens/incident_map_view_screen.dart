import 'package:flutter/material.dart';

class IncidentMapViewScreen extends StatelessWidget {
  const IncidentMapViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final incidents = [
      {'type': 'Suspicious Activity', 'location': 'Oak St & 1st Ave', 'date': '2025-06-18'},
      {'type': 'Vandalism', 'location': 'Maple Ave', 'date': '2025-06-15'},
      {'type': 'Theft', 'location': 'Downtown', 'date': '2025-06-10'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Map View', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100, width: 1.2),
              ),
              child: const Center(
                child: Text('Map Placeholder\n(Integrate Google Maps/Mapbox here)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF36599F), fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Color(0xFF36599F)),
                    title: Text(incident['type']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${incident['location']}\n${incident['date']}', style: const TextStyle(fontSize: 13)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}