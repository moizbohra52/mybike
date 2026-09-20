import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Single cell in a report table
class ReportCell extends Equatable {
  final String text;
  final TextAlign align;
  final bool isBold;
  final Color? textColor;
  final double? numericValue;

  const ReportCell({
    required this.text,
    this.align = TextAlign.left,
    this.isBold = false,
    this.textColor,
    this.numericValue,
  });

  @override
  List<Object?> get props => [text, align, isBold, textColor, numericValue];
}

/// Generic row item for report tables
class ReportRowItem extends Equatable {
  final String id;
  final List<ReportCell> cells;
  final bool isHeader;
  final bool isTotalRow;
  final bool isSubtotalRow;
  final Map<String, dynamic>? rawData;

  const ReportRowItem({
    required this.id,
    required this.cells,
    this.isHeader = false,
    this.isTotalRow = false,
    this.isSubtotalRow = false,
    this.rawData,
  });

  @override
  List<Object?> get props => [id, cells, isHeader, isTotalRow, isSubtotalRow, rawData];
}

/// Report column definition
class ReportColumnDef extends Equatable {
  final String title;
  final TextAlign align;
  final double? width;
  final int flex;

  const ReportColumnDef({
    required this.title,
    this.align = TextAlign.left,
    this.width,
    this.flex = 1,
  });

  @override
  List<Object?> get props => [title, align, width, flex];
}
