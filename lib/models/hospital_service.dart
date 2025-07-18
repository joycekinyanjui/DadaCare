class HospitalService {
  final String facility;
  final String region;
  final String category;
  final String service;
  final double baseCost;
  final String nhifCovered;
  final double insuranceCopay;
  final double outOfPocket;

  HospitalService({
    required this.facility,
    required this.region,
    required this.category,
    required this.service,
    required this.baseCost,
    required this.nhifCovered,
    required this.insuranceCopay,
    required this.outOfPocket,
  });

  factory HospitalService.fromJson(Map<String, dynamic> json) {
    return HospitalService(
      facility: json['Facility'],
      region: json['Region'],
      category: json['Category'],
      service: json['Service'],
      baseCost: (json['Base Cost (KES)'] as num).toDouble(),
      nhifCovered: json['NHIF Covered'],
      insuranceCopay: (json['Insurance Copay (KES)'] as num).toDouble(),
      outOfPocket: (json['Out-of-Pocket (KES)'] as num).toDouble(),
    );
  }
}
