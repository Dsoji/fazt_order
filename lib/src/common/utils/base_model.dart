// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BaseModel {
  final dynamic status;
  final int? statusCode;
  final String? message;
  final dynamic data;
  final dynamic predictions;
  final dynamic result;

  BaseModel({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
    required this.predictions,
    required this.result,
  });

  BaseModel copyWith({
    dynamic status,
    int? statusCode,
    String? message,
    dynamic data,
    dynamic predictions,
    dynamic result,
  }) {
    return BaseModel(
      status: status ?? this.status,
      statusCode: statusCode ?? this.statusCode,
      message: message ?? this.message,
      data: data ?? this.data,
      predictions: predictions ?? this.predictions,
      result: result ?? this.result,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'message': message,
      'data': data,
      'predictions': predictions,
      'result': result,
    };
  }

  static String toRawString(dynamic data) => data.toString();

  factory BaseModel.fromMap(Map<String, dynamic> map) {
    return BaseModel(
      status: map['status'] != null ? map['status'] as dynamic : null,
      statusCode: map['statusCode'] != null ? map['statusCode'] as int : null,
      message: map['message'] != null ? map['message'] as String : null,
      data: map['data'] as dynamic,
      predictions: map['predictions'] as dynamic,
      result: map['result'] as dynamic,
    );
  }

  String toJson() => json.encode(toMap());

  factory BaseModel.fromJson(String source) =>
      BaseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'BaseModel(status: $status, statusCode: $statusCode, message: $message, data: $data)';
  }

  @override
  bool operator ==(covariant BaseModel other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        other.statusCode == statusCode &&
        other.message == message &&
        other.data == data;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        statusCode.hashCode ^
        message.hashCode ^
        data.hashCode;
  }
}
