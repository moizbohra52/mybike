import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Generic Data Point for Analytics Visual Charts
class ChartDataPoint extends Equatable {
  final String label; // e.g. "Apr", "Honda", "Petrol"
  final double value; // Primary numerical value
  final double? secondaryValue; // Optional secondary series value (e.g. Target, Inward)
  final String? displayValue; // Formatted string e.g. "₹14.2 L", "38 units"
  final Color? color;
  final double? percentage; // 0.0 to 100.0

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.secondaryValue,
    this.displayValue,
    this.color,
    this.percentage,
  });

  @override
  List<Object?> get props => [label, value, secondaryValue, displayValue, color, percentage];
}
