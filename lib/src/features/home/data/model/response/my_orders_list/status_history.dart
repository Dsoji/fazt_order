class StatusHistory {
  String? status;
  DateTime? timestamp;
  String? updatedBy;
  String? notes;
  String? id;

  StatusHistory({
    this.status,
    this.timestamp,
    this.updatedBy,
    this.notes,
    this.id,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      status: json['status'] as String?,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      updatedBy: json['updatedBy'] as String?,
      notes: json['notes'] as String?,
      id: json['_id'] as String?,
    );
  }

  factory StatusHistory.fromMap(Map<String, dynamic> data) {
    return StatusHistory(
      status: data['status'] as String?,
      timestamp: data['timestamp'] == null
          ? null
          : DateTime.parse(data['timestamp'] as String),
      updatedBy: data['updatedBy'] as String?,
      notes: data['notes'] as String?,
      id: data['_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'timestamp': timestamp?.toIso8601String(),
      'updatedBy': updatedBy,
      'notes': notes,
      '_id': id,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp': timestamp?.toIso8601String(),
      'updatedBy': updatedBy,
      'notes': notes,
      '_id': id,
    };
  }

  @override
  String toString() {
    return 'StatusHistory(status: $status, timestamp: $timestamp, updatedBy: $updatedBy, notes: $notes, id: $id)';
  }

  StatusHistory copyWith({
    String? status,
    DateTime? timestamp,
    String? updatedBy,
    String? notes,
    String? id,
  }) {
    return StatusHistory(
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      updatedBy: updatedBy ?? this.updatedBy,
      notes: notes ?? this.notes,
      id: id ?? this.id,
    );
  }
}
