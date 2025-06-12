import 'package:flutter/material.dart';

class PaymentHistory {
  final String source;
  final double before;
  final double after;
  final double amount;
  final String destination;
  final String? stationId;
  final String? note;

  PaymentHistory({
    required this.source,
    required this.before,
    required this.after,
    required this.amount,
    required this.destination,
    this.stationId,
    this.note,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      source: json['source'] as String,
      before: (json['before'] as num).toDouble(),
      after: (json['after'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      destination: json['destination'] as String,
      stationId: json['stationId'] as String?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'before': before,
      'after': after,
      'amount': amount,
      'destination': destination,
      'stationId': stationId,
      'note': note,
    };
  }
}