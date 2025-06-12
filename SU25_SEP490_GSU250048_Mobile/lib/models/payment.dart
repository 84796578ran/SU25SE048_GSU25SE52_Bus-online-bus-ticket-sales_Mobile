import 'package:flutter/material.dart';

class Payment {
  final String method;
  final DateTime createdAt;
  final double totalPrice;
  final String? systemUserId;
  final int status;
  final String? note;
  final String reservationId;
  final String paymentHistoryId;

  Payment({
    required this.method,
    required this.createdAt,
    required this.totalPrice,
    this.systemUserId,
    required this.status,
    this.note,
    required this.reservationId,
    required this.paymentHistoryId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      method: json['method'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      systemUserId: json['systemUserId'] as String?,
      status: json['status'] as int,
      note: json['note'] as String?,
      reservationId: json['reservationId'] as String,
      paymentHistoryId: json['paymentHistoryId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'createdAt': createdAt.toIso8601String(),
      'totalPrice': totalPrice,
      'systemUserId': systemUserId,
      'status': status,
      'note': note,
      'reservationId': reservationId,
      'paymentHistoryId': paymentHistoryId,
    };
  }
}