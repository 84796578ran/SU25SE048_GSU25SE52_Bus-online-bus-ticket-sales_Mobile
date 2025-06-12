import 'package:flutter/material.dart';

class Seat {
  final String id;
  final String status;
  final String location;
  final String? ticketId;
  final double price;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String tripId;
  final String? reservationId;

  Seat({
    required this.id,
    required this.status,
    required this.location,
    this.ticketId,
    required this.price,
    required this.createdAt,
    this.updatedAt,
    required this.tripId,
    this.reservationId,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'] as String,
      status: json['status'] as String,
      location: json['location'] as String,
      ticketId: json['ticketId'] as String?,
      price: (json['price'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      tripId: json['tripId'] as String,
      reservationId: json['reservationId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'location': location,
      'ticketId': ticketId,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'tripId': tripId,
      'reservationId': reservationId,
    };
  }
}