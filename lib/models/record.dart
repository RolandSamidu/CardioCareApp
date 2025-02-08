class Record {
  final String user;
  final String prediction;
  final String date;
  final String time;
  final String doctorVerification;

  Record({
    required this.user,
    required this.prediction,
    required this.date,
    required this.time,
    required this.doctorVerification,
  });

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      user: json['user'],
      prediction: json['prediction'],
      date: json['Date'],
      time: json['Time'],
      doctorVerification: json['DoctorVeri'],
    );
  }
}