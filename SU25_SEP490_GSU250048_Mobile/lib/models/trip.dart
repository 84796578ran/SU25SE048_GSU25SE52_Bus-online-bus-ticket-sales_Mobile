import 'package:flutter/material.dart';
import 'package:mobile/models/enum/tripStatus.dart';

class Trip {
  final String id;
  final double price;
  final TripStatus status;
  final DateTime timeStart;
  final DateTime timeEnd;
  final String? description;
  final String typeBusId;
  final String fromLocation;
  final String endLocation;

  Trip({
    required this.id,
    required this.price,
    required this.status,
    required this.timeStart,
    required this.timeEnd,
    this.description,
    required this.typeBusId,
    required this.fromLocation,
    required this.endLocation,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      price: (json['price'] as num).toDouble(),
      status: TripStatus.fromInt(json['status'] as int),
      timeStart: DateTime.parse(json['timeStart'] as String),
      timeEnd: DateTime.parse(json['timeEnd'] as String),
      description: json['description'] as String?,
      typeBusId: json['typeBusId'] as String,
      fromLocation: json['fromLocation'] as String,
      endLocation: json['endLocation'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'status': status,
      'timeStart': timeStart.toIso8601String(),
      'timeEnd': timeEnd.toIso8601String(),
      'description': description,
      'typeBusId': typeBusId,
      'fromLocation': fromLocation,
      'endLocation': endLocation,
    };
  }
}