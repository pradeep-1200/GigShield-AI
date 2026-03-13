class WorkerModel {
  String name;
  String city;
  int weeklyIncome;
  int workingHours;
  String platform;
  double riskScore;
  double premium;
  double coverage;
  Map<String, dynamic>? weatherData;
  String? aiExplanation;
  String policyId;
  String activationDate;

  WorkerModel({
    required this.name,
    required this.city,
    required this.weeklyIncome,
    required this.workingHours,
    required this.platform,
    this.riskScore = 0.0,
    this.premium = 0.0,
    this.coverage = 0.0,
    this.weatherData,
    this.aiExplanation,
  }) : policyId = 'GS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
       activationDate = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
}
