import 'package:flutter/material.dart';
import 'package:mobile/models/enum/tripStatus.dart';

class Trip {
  final int id;
  final String tripId;
  final double price;
  final TripStatus status;
  final DateTime timeStart;
  final DateTime timeEnd;
  final String? description;
  final String busName;
  final String fromLocation;
  final String endLocation;
  final String? routeDescription;
  final int? routeId;
  final bool? isDeleted;
  final int? fromStationId; // THÊM TRƯỜNG NÀY
  final int? toStationId;   // THÊM TRƯỜNG NÀY

  Trip({
    required this.id,
    required this.tripId,
    required this.price,
    required this.status,
    required this.timeStart,
    required this.timeEnd,
    this.description,
    required this.busName,
    required this.fromLocation,
    required this.endLocation,
    this.routeDescription,
    this.routeId,
    this.isDeleted,
    this.fromStationId, // THÊM VÀO CONSTRUCTOR
    this.toStationId,   // THÊM VÀO CONSTRUCTOR
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: (json['id'] as int?) ?? 0,
      tripId: (json['tripId'] as String?) ?? 'N/A',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: TripStatus.fromInt((json['status'] as int?) ?? 0),
      timeStart: DateTime.parse(json['timeStart'] as String),
      timeEnd: DateTime.parse(json['timeEnd'] as String),
      description: json['description'] as String?,
      busName: (json['busName'] as String?) ?? 'N/A',
      fromLocation: (json['fromLocation'] as String?) ?? 'N/A',
      endLocation: (json['endLocation'] as String?) ?? 'N/A',
      routeDescription: json['routeDescription'] as String?,
      routeId: (json['routeId'] as int?),
      isDeleted: (json['isDeleted'] as bool?) ?? false,
      fromStationId: (json['fromStationId'] as int?), // LẤY TỪ JSON
      toStationId: (json['toStationId'] as int?),     // LẤY TỪ JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'price': price,
      'status': status.index,
      'timeStart': timeStart.toIso8601String(),
      'timeEnd': timeEnd.toIso8601String(),
      'description': description,
      'busName': busName,
      'fromLocation': fromLocation,
      'endLocation': endLocation,
      'routeDescription': routeDescription,
      'routeId': routeId,
      'isDeleted': isDeleted,
      'fromStationId': fromStationId, // BAO GỒM TRONG toJson
      'toStationId': toStationId,     // BAO GỒM TRONG toJson
    };
  }
}