import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';

import '../../features/reports/domain/entities/report_row_item.dart';

/// Builder for CSV and Microsoft Excel SpreadsheetML (.xls/.xml) Exports
class SpreadsheetExportBuilder {
  SpreadsheetExportBuilder._();

  /// Generates RFC 4180 compliant CSV string
  static String buildCsvString({
    required List<ReportColumnDef> columns,
    required List<ReportRowItem> rows,
  }) {
    final List<List<dynamic>> csvData = [];

    // Header row
    csvData.add(columns.map((c) => c.title).toList());

    // Data rows
    for (final row in rows) {
      final List<dynamic> rowData = [];
      for (int i = 0; i < columns.length; i++) {
        if (i < row.cells.length) {
          final cell = row.cells[i];
          if (cell.numericValue != null) {
            rowData.add(cell.numericValue);
          } else {
            rowData.add(cell.text);
          }
        } else {
          rowData.add('');
        }
      }
      csvData.add(rowData);
    }

    return Csv().encode(csvData);
  }

  /// Generates CSV from raw headers and rows
  static String buildCsv({
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    final List<List<dynamic>> csvData = [headers, ...rows];
    return Csv().encode(csvData);
  }

  /// Generates CSV as byte array (UTF-8 with optional BOM for seamless Excel opening)
  static Uint8List buildCsvBytes({
    required List<ReportColumnDef> columns,
    required List<ReportRowItem> rows,
    bool includeBom = true,
  }) {
    final List<List<dynamic>> csvData = [];

    // Header row
    csvData.add(columns.map((c) => c.title).toList());

    // Data rows
    for (final row in rows) {
      final List<dynamic> rowData = [];
      for (int i = 0; i < columns.length; i++) {
        if (i < row.cells.length) {
          final cell = row.cells[i];
          if (cell.numericValue != null) {
            rowData.add(cell.numericValue);
          } else {
            rowData.add(cell.text);
          }
        } else {
          rowData.add('');
        }
      }
      csvData.add(rowData);
    }

    final String csvString = Csv(addBom: includeBom).encode(csvData);
    return Uint8List.fromList(utf8.encode(csvString));
  }

  /// Generates Microsoft Excel SpreadsheetML (.xls/.xml) with rich styles, bold headers,
  /// numeric types, and sheet formatting.
  static String buildExcelXml({
    required String sheetName,
    required String title,
    required List<ReportColumnDef> columns,
    required List<ReportRowItem> rows,
    String? subtitle,
  }) {
    final StringBuffer buffer = StringBuffer();

    final String safeSheetName = sheetName
        .replaceAll(RegExp(r'[:\\/?*\[\]]'), '_')
        .trim();
    final String validSheetName = safeSheetName.isEmpty
        ? 'Report'
        : (safeSheetName.length > 31 ? safeSheetName.substring(0, 31) : safeSheetName);

    buffer.writeln('<?xml version="1.0"?>');
    buffer.writeln('<?mso-application progid="Excel.Sheet"?>');
    buffer.writeln('<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"');
    buffer.writeln(' xmlns:o="urn:schemas-microsoft-com:office:office"');
    buffer.writeln(' xmlns:x="urn:schemas-microsoft-com:office:excel"');
    buffer.writeln(' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"');
    buffer.writeln(' xmlns:html="http://www.w3.org/TR/REC-html40">');

    // Styles
    buffer.writeln(' <Styles>');
    // Default
    buffer.writeln('  <Style ss:ID="Default" ss:Name="Normal">');
    buffer.writeln('   <Alignment ss:Vertical="Center"/>');
    buffer.writeln('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="10" ss:Color="#1E293B"/>');
    buffer.writeln('  </Style>');

    // Title Style
    buffer.writeln('  <Style ss:ID="sTitle">');
    buffer.writeln('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="14" ss:Bold="1" ss:Color="#0F766E"/>');
    buffer.writeln('   <Alignment ss:Vertical="Center"/>');
    buffer.writeln('  </Style>');

    // Subtitle Style
    buffer.writeln('  <Style ss:ID="sSubtitle">');
    buffer.writeln('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="9" ss:Italic="1" ss:Color="#64748B"/>');
    buffer.writeln('  </Style>');

    // Header Style
    buffer.writeln('  <Style ss:ID="sHeader">');
    buffer.writeln('   <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>');
    buffer.writeln('   <Borders>');
    buffer.writeln('    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#0F172A"/>');
    buffer.writeln('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#0F172A"/>');
    buffer.writeln('   </Borders>');
    buffer.writeln('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="10" ss:Bold="1" ss:Color="#FFFFFF"/>');
    buffer.writeln('   <Interior ss:Color="#0F172A" ss:Pattern="Solid"/>');
    buffer.writeln('  </Style>');

    // Standard Text Left
    buffer.writeln('  <Style ss:ID="sText">');
    buffer.writeln('   <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>');
    buffer.writeln('   <Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders>');
    buffer.writeln('  </Style>');

    // Standard Text Center
    buffer.writeln('  <Style ss:ID="sCenter">');
    buffer.writeln('   <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>');
    buffer.writeln('   <Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders>');
    buffer.writeln('  </Style>');

    // Standard Number Right
    buffer.writeln('  <Style ss:ID="sNumber">');
    buffer.writeln('   <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>');
    buffer.writeln('   <NumberFormat ss:Format="#,##0.00"/>');
    buffer.writeln('   <Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#E2E8F0"/></Borders>');
    buffer.writeln('  </Style>');

    // Total Row Bold Text
    buffer.writeln('  <Style ss:ID="sTotalText">');
    buffer.writeln('   <Alignment ss:Horizontal="Left" ss:Vertical="Center"/>');
    buffer.writeln('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="10" ss:Bold="1" ss:Color="#0F172A"/>');
    buffer.writeln('   <Interior ss:Color="#E2E8F0" ss:Pattern="Solid"/>');
    buffer.writeln('   <Borders>');
    buffer.writeln('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#0F172A"/>');
    buffer.writeln('    <Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3" ss:Color="#0F172A"/>');
    buffer.writeln('   </Borders>');
    buffer.writeln('  </Style>');

    // Total Row Bold Number
    buffer.writeln('  <Style ss:ID="sTotalNumber">');
    buffer.writeln('   <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>');
    buffer.writeln('   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="10" ss:Bold="1" ss:Color="#0F172A"/>');
    buffer.writeln('   <NumberFormat ss:Format="#,##0.00"/>');
    buffer.writeln('   <Interior ss:Color="#E2E8F0" ss:Pattern="Solid"/>');
    buffer.writeln('   <Borders>');
    buffer.writeln('    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#0F172A"/>');
    buffer.writeln('    <Border ss:Position="Bottom" ss:LineStyle="Double" ss:Weight="3" ss:Color="#0F172A"/>');
    buffer.writeln('   </Borders>');
    buffer.writeln('  </Style>');

    buffer.writeln(' </Styles>');

    // Worksheet
    buffer.writeln(' <Worksheet ss:Name="$validSheetName">');
    buffer.writeln('  <Table ss:DefaultColumnWidth="100">');

    // Title Row
    buffer.writeln('   <Row ss:Height="24">');
    buffer.writeln('    <Cell ss:StyleID="sTitle"><Data ss:Type="String">${_escapeXml(title)}</Data></Cell>');
    buffer.writeln('   </Row>');

    if (subtitle != null && subtitle.isNotEmpty) {
      buffer.writeln('   <Row ss:Height="16">');
      buffer.writeln('    <Cell ss:StyleID="sSubtitle"><Data ss:Type="String">${_escapeXml(subtitle)}</Data></Cell>');
      buffer.writeln('   </Row>');
    }

    // Blank row
    buffer.writeln('   <Row ss:Height="8"/>');

    // Column Headers
    buffer.writeln('   <Row ss:Height="20">');
    for (final col in columns) {
      buffer.writeln('    <Cell ss:StyleID="sHeader"><Data ss:Type="String">${_escapeXml(col.title)}</Data></Cell>');
    }
    buffer.writeln('   </Row>');

    // Rows
    for (final row in rows) {
      buffer.writeln('   <Row ss:Height="18">');
      for (int i = 0; i < columns.length; i++) {
        final cell = i < row.cells.length ? row.cells[i] : null;
        if (cell == null) {
          buffer.writeln('    <Cell><Data ss:Type="String"></Data></Cell>');
          continue;
        }

        final bool isTotal = row.isTotalRow || row.isSubtotalRow;

        if (cell.numericValue != null) {
          final String styleId = isTotal ? 'sTotalNumber' : 'sNumber';
          buffer.writeln('    <Cell ss:StyleID="$styleId"><Data ss:Type="Number">${cell.numericValue}</Data></Cell>');
        } else {
          final String styleId = isTotal ? 'sTotalText' : 'sText';
          buffer.writeln('    <Cell ss:StyleID="$styleId"><Data ss:Type="String">${_escapeXml(cell.text)}</Data></Cell>');
        }
      }
      buffer.writeln('   </Row>');
    }

    buffer.writeln('  </Table>');
    buffer.writeln(' </Worksheet>');
    buffer.writeln('</Workbook>');

    return buffer.toString();
  }

  /// Generates Excel XML as UTF-8 bytes
  static Uint8List buildExcelXmlBytes({
    required String sheetName,
    required String title,
    required List<ReportColumnDef> columns,
    required List<ReportRowItem> rows,
    String? subtitle,
  }) {
    final String xmlString = buildExcelXml(
      sheetName: sheetName,
      title: title,
      columns: columns,
      rows: rows,
      subtitle: subtitle,
    );
    return Uint8List.fromList(utf8.encode(xmlString));
  }

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
