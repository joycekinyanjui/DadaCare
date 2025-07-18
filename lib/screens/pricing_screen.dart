import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/hospital_service.dart';

class PricingPage extends StatefulWidget {
  const PricingPage({super.key});

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  List<HospitalService> services = [];
  List<String> facilities = [];
  String? selectedFacility;
  List<HospitalService> filteredServices = [];

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final String jsonString = await rootBundle.loadString(
      'assets/hospitals.json',
    );
    final List<dynamic> jsonResponse = json.decode(jsonString);

    final loadedServices =
        jsonResponse.map((e) => HospitalService.fromJson(e)).toList();

    setState(() {
      services = loadedServices;
      facilities = services.map((e) => e.facility).toSet().toList();
    });
  }

  void filter() {
    if (selectedFacility == null) {
      setState(() {
        filteredServices = [];
      });
      return;
    }

    final filtered = services.where((s) => s.facility == selectedFacility);
    setState(() {
      filteredServices = filtered.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Hospital Service Pricing"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Facility dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Facility",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              value: selectedFacility,
              items:
                  facilities
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFacility = value;
                });
                filter();
              },
            ),
            const SizedBox(height: 20),

            // List of services
            Expanded(
              child:
                  filteredServices.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No services to display.\nPlease select a facility above.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.separated(
                        itemCount: filteredServices.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final s = filteredServices[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            elevation: 3,
                            child: ListTile(
                              leading: const Icon(
                                Icons.local_hospital,
                                color: Colors.lightBlue,
                              ),
                              title: Text(
                                s.service,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Category: ${s.category}"),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Base: KES ${s.baseCost.toStringAsFixed(2)}",
                                    ),
                                    Text("NHIF: ${s.nhifCovered}"),
                                    Text(
                                      "Copay: KES ${s.insuranceCopay.toStringAsFixed(2)}",
                                    ),
                                    Text(
                                      "Out-of-pocket: KES ${s.outOfPocket.toStringAsFixed(2)}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
