enum Frequency {
  qd,
  bid,
  tid,
  qhs,
  prn,
}

extension FrequencyExtension on Frequency {
  String get code {
    switch (this) {
      case Frequency.qd:
        return 'QD';
      case Frequency.bid:
        return 'BID';
      case Frequency.tid:
        return 'TID';
      case Frequency.qhs:
        return 'QHS';
      case Frequency.prn:
        return 'PRN';
    }
  }

  String get displayName {
    switch (this) {
      case Frequency.qd:
        return 'Once Daily';
      case Frequency.bid:
        return 'Twice Daily';
      case Frequency.tid:
        return 'Three Times Daily';
      case Frequency.qhs:
        return 'At Bedtime';
      case Frequency.prn:
        return 'As Needed';
    }
  }

  static Frequency? fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'QD':
        return Frequency.qd;
      case 'BID':
        return Frequency.bid;
      case 'TID':
        return Frequency.tid;
      case 'QHS':
        return Frequency.qhs;
      case 'PRN':
        return Frequency.prn;
      default:
        return null;
    }
  }

  static Frequency? fromDisplayName(String displayName) {
    switch (displayName) {
      case 'Once Daily':
        return Frequency.qd;
      case 'Twice Daily':
        return Frequency.bid;
      case 'Three Times Daily':
        return Frequency.tid;
      case 'At Bedtime':
        return Frequency.qhs;
      case 'As Needed':
        return Frequency.prn;
      default:
        return null;
    }
  }

  static List<Frequency> get values => [
        Frequency.qd,
        Frequency.bid,
        Frequency.tid,
        Frequency.qhs,
        Frequency.prn,
      ];

  static List<String> get displayNames =>
      values.map((e) => e.displayName).toList();

  static List<String> get codes => values.map((e) => e.code).toList();
}

class Treatment {
  final int? id;
  final String? medicineName;
  final int? remainingQuantity;
  final String? dosage;
  final Frequency? frequency;
  final int prescribedQuantity;
  final int dispensedQuantity;
  final String? startDate;
  final int? durationDays;
  final int medicalRecord;
  final int medicine;
  final String? notes;

  Treatment({
    this.id,
    this.medicineName,
    this.remainingQuantity,
    this.dosage,
    this.frequency,
    required this.prescribedQuantity,
    required this.dispensedQuantity,
    this.startDate,
    this.durationDays,
    required this.medicalRecord,
    required this.medicine,
    this.notes,
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      id: json['id'],
      medicineName: json['medicine_name'],
      remainingQuantity: json['remaining_quantity'],
      dosage: json['dosage'],
      frequency: FrequencyExtension.fromCode(json['frequency']),
      prescribedQuantity: json['prescribed_quantity'],
      dispensedQuantity: json['dispensed_quantity'],
      startDate: json['start_date'],
      durationDays: json['duration_days'],
      medicalRecord: json['medical_record'],
      medicine: json['medicine'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (medicineName != null) 'medicine_name': medicineName,
      if (remainingQuantity != null) 'remaining_quantity': remainingQuantity,
      if (dosage != null) 'dosage': dosage,
      if (frequency != null) 'frequency': frequency?.code,
      'prescribed_quantity': prescribedQuantity,
      'dispensed_quantity': dispensedQuantity,
      if (startDate != null) 'start_date': startDate,
      if (durationDays != null) 'duration_days': durationDays,
      // 'medical_record': medicalRecord,
      'medicine': medicine,
      if (notes != null) 'notes': notes,
    };
  }

  Treatment copyWith({
    int? id,
    String? medicineName,
    int? remainingQuantity,
    String? dosage,
    Frequency? frequency,
    int? prescribedQuantity,
    int? dispensedQuantity,
    String? startDate,
    int? durationDays,
    int? medicalRecord,
    int? medicine,
    String? notes,
  }) {
    return Treatment(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      prescribedQuantity: prescribedQuantity ?? this.prescribedQuantity,
      dispensedQuantity: dispensedQuantity ?? this.dispensedQuantity,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      medicalRecord: medicalRecord ?? this.medicalRecord,
      medicine: medicine ?? this.medicine,
      notes: notes ?? this.notes,
    );
  }
}
