import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'PoseHomeScreen.dart';

class PosturePdfService {

  // ── Brand colours (exact match to invoice screenshot) ─────────────────────
  static const _cyan        = PdfColor.fromInt(0xFF17B8C4);
  static const _headerBg    = PdfColor.fromInt(0xFFE8F6F8);
  static const _boxBorder   = PdfColor.fromInt(0xFFCBE8EE);
  static const _tableHeader = PdfColor.fromInt(0xFF17B8C4);
  static const _totalBg     = PdfColor.fromInt(0xFF1BAFC6);
  static const _rowAlt      = PdfColor.fromInt(0xFFF4FBFC);
  static const _textDark    = PdfColor.fromInt(0xFF1A1A2E);
  static const _textMid     = PdfColor.fromInt(0xFF555555);
  static const _textLight   = PdfColor.fromInt(0xFF888888);
  static const _divider     = PdfColor.fromInt(0xFFDDDDDD);


  // ── Helpers ────────────────────────────────────────────────────────────────
  static PdfColor _statusColor(String s) {
    switch (s) {
      case 'good':     return const PdfColor.fromInt(0xFF2E7D32);
      case 'mild':     return const PdfColor.fromInt(0xFFFFA000);
      case 'moderate': return const PdfColor.fromInt(0xFFF57C00);
      case 'severe':   return const PdfColor.fromInt(0xFFC62828);
      default:         return PdfColors.grey;
    }
  }

  static String _statusLabel(String s) {
    switch (s) {
      case 'good':     return 'Good';
      case 'mild':     return 'Mild';
      case 'moderate': return 'Moderate';
      case 'severe':   return 'Severe';
      default:         return 'Unknown';
    }
  }

  static String _overallText(String s) {
    switch (s) {
      case 'good':     return 'GOOD POSTURE';
      case 'mild':     return 'MILD ISSUES';
      case 'moderate': return 'NEEDS ATTENTION';
      case 'severe':   return 'SEE SPECIALIST';
      default:         return 'UNKNOWN';
    }
  }
  static String _pad(int n) => n.toString().padLeft(2, '0');
  static Future<File> generateReport({
    required Uint8List measurementImage,
    required PostureReport report,
  }) async
  {

    final pdf = pw.Document();

    final pdfImage = pw.MemoryImage(measurementImage);

    final now = DateTime.now();
    final dateStr = '${_pad(now.day)}/${_pad(now.month)}/${now.year}';

    final reportNo =
        'RPT ${now.millisecondsSinceEpoch.toString().substring(6)}';

    final logoBytes =
    (await rootBundle.load('assert/image/splashscreen.png'))
        .buffer
        .asUint8List();

    final logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        header: (ctx) => _buildPageHeader(dateStr, reportNo, ctx.pageNumber, logoImage),
        footer: (_)   => _buildFooter(),
        build: (ctx)  => [
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(28, 18, 28, 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                // ── FROM / ANALYSIS INFO boxes ───────────────────────
                _buildInfoBoxes(report, dateStr),
                pw.SizedBox(height: 20),

                // ── Overall status banner ────────────────────────────
                _buildStatusBar(report),
                pw.SizedBox(height: 8),
                pw.Text(
                  report.summary,
                  style: pw.TextStyle(
                    fontSize: 8.8, color: _textMid, lineSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 20),

                // ── Posture image (centred) ───────────────────────────
                _buildImageSection(pdfImage),
                pw.SizedBox(height: 22),

                // ── A. Front View measurements ───────────────────────
                _sectionLabel('A.  FRONT VIEW  MEASUREMENTS'),
                pw.SizedBox(height: 6),
                _buildMeasTable(
                  report.measurements
                      .where((m) => m.code.startsWith('A'))
                      .toList(),
                ),
                pw.SizedBox(height: 16),

                // ── B. Side View measurements ────────────────────────
                _sectionLabel('B.  RIGHT SIDE MEASUREMENTS'),
                pw.SizedBox(height: 6),
                _buildMeasTable(
                  report.measurements
                      .where((m) => m.code.startsWith('B'))
                      .toList(),
                ),
                pw.SizedBox(height: 16),

                // ── Detailed findings ────────────────────────────────
                _sectionLabel('DETAILED FINDINGS'),
                pw.SizedBox(height: 6),
                _buildFindingsTable(report.measurements),
                pw.SizedBox(height: 16),

                // ── Issues detected ──────────────────────────────────
                if (report.problems.isNotEmpty) ...[
                  _sectionLabel('ISSUES DETECTED'),
                  pw.SizedBox(height: 6),
                  _buildIssuesList(report.problems),
                  pw.SizedBox(height: 16),
                ],

                // ── Score summary pills ──────────────────────────────
                _buildScoreRow(report),
                pw.SizedBox(height: 22),

                // ── Exercises table ───────────────────────────────────
                _sectionLabel('RECOMMENDED CORRECTIVE EXERCISES'),
                pw.SizedBox(height: 6),
                _buildExercisesTable(report.exercises),
                pw.SizedBox(height: 22),

                // ── TOTAL bar (invoice-style) ─────────────────────────
                _buildTotalBar(report),
                pw.SizedBox(height: 10),

              ],
            ),
          ),
        ],
      ),
    );
    final dir  = await getTemporaryDirectory();
    final file = File('${dir.path}/zeromedixine_posture_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildPageHeader(
      String dateStr,
      String reportNo,
      int page,
      pw.MemoryImage logoImage,
      )
  {
    return pw.Container(
      width: double.infinity,
      color: _headerBg,
      padding: const pw.EdgeInsets.fromLTRB(28, 18, 28, 18),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          // ── Logo ───────────────────────────────────────────────────
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: 150,
                height: 165,   
                child: pw.Image(
                  logoImage,
                  fit: pw.BoxFit.contain,
                ),
              ),
            ],
          ),
          // ── Title + meta ───────────────────────────────────────────
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'POSTURE REPORT',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: _cyan,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text('Report No: $reportNo',
                  style: pw.TextStyle(fontSize: 8.5, color: _textMid)),
              pw.Text('Date: $dateStr  |  Page $page',
                  style: pw.TextStyle(fontSize: 8.5, color: _textMid)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoBoxes(PostureReport report, String dateStr) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _infoBox(label: 'FROM', lines: [
            'Zeromedixine Clinic',
            'support@zeromedixine.com',
            '+91 98765 43210',
          ]),
        ),
        pw.SizedBox(width: 16),
        pw.Expanded(
          child: _infoBox(label: 'ANALYSIS INFO', lines: [
            'AI Posture Analysis',
            'Date: $dateStr',
            'Engine: GOOGLE · ML Kit',
            'Status: ${_overallText(report.overallStatus)}',
          ]),
        ),
      ],
    );
  }

  static pw.Widget _infoBox(
      {required String label, required List<String> lines})
  {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _boxBorder, width: 1),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: _tableHeader,
                letterSpacing: 0.8,
              )),
          pw.SizedBox(height: 6),
          ...lines.map((l) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Text(l,
                style: pw.TextStyle(fontSize: 9, color: _textMid)),
          )),
        ],
      ),
    );
  }

  static pw.Widget _buildStatusBar(PostureReport report) {
    final color = _statusColor(report.overallStatus);
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'OVERALL STATUS: ${_overallText(report.overallStatus)}',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.Text('Zeromedixine AI Posture Assessment',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.white)),
        ],
      ),
    );
  }


  static pw.Widget _buildImageSection(pw.MemoryImage img) {
    return pw.Center(
      child: pw.Container(
        width: 220,
        height: 260,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _boxBorder, width: 1),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.ClipRRect(
          horizontalRadius: 4,
          verticalRadius: 4,
          child: pw.Image(img, fit: pw.BoxFit.contain),
        ),
      ),
    );
  }

  static pw.Widget _sectionLabel(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: const pw.BoxDecoration(
        color: _headerBg,
        border: pw.Border(
          left: pw.BorderSide(color: _cyan, width: 3),
        ),
      ),
      child: pw.Text(title,
          style: pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            color: _textDark,
            letterSpacing: 0.4,
          )),
    );
  }

  static pw.Widget _buildMeasTable(List<PostureMeasurement> items) {
    pw.Widget hCell(String t,
        {pw.Alignment align = pw.Alignment.centerLeft}) =>
        pw.Container(
          padding:
          const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: pw.Align(
            alignment: align,
            child: pw.Text(t,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _tableHeader,
                )),
          ),
        );

    pw.Widget dCell(String t, {
      pw.Alignment align = pw.Alignment.centerLeft,
      PdfColor color     = _textDark,
      bool bold          = false,
    }) =>
        pw.Container(
          padding:
          const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          child: pw.Align(
            alignment: align,
            child: pw.Text(t,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  color: color,
                  fontWeight: bold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                )),
          ),
        );

    return pw.Table(
      border: pw.TableBorder(
        bottom: const pw.BorderSide(color: _divider, width: 0.6),
        horizontalInside:
        const pw.BorderSide(color: _divider, width: 0.5),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.8),
        1: pw.FlexColumnWidth(2.8),
        2: pw.FlexColumnWidth(1.2),
        3: pw.FlexColumnWidth(1.4),
        4: pw.FlexColumnWidth(4.0),
      },
      children: [
        // Header row
        pw.TableRow(children: [
          hCell('Code'),
          hCell('Section'),
          hCell('Angle', align: pw.Alignment.center),
          hCell('Status', align: pw.Alignment.center),
          hCell('Finding'),
        ]),
        // Cyan separator line
        pw.TableRow(
          children: List.generate(
            5,
                (_) => pw.Container(height: 1.2, color: _cyan),
          ),
        ),
        // Data rows
        ...items.asMap().entries.map((entry) {
          final i  = entry.key;
          final m  = entry.value;
          final sc = _statusColor(m.status);
          final bg = i.isEven ? _rowAlt : PdfColors.white;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              dCell(m.code, bold: true, color: sc),
              dCell(m.label),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: pw.Center(
                  child: pw.Text(
                    '${m.angleDeg.toStringAsFixed(1)}°',
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 5, vertical: 3),
                child: pw.Center(
                  child:
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: pw.BoxDecoration(
                      color: sc,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      _statusLabel(m.status),
                      style: pw.TextStyle(
                        fontSize: 7.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              dCell(m.finding, color: _textMid),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildFindingsTable(
      List<PostureMeasurement> measurements)
  {
    return pw.Table(
      border: pw.TableBorder.all(color: _boxBorder, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.6),
        1: pw.FlexColumnWidth(2.0),
        2: pw.FlexColumnWidth(5.5),
        3: pw.FlexColumnWidth(1.0),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _headerBg),
          children: ['#', 'Measurement', 'Finding', 'Angle']
              .map((h) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 8, vertical: 7),
            child: pw.Text(h,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _tableHeader,
                )),
          ))
              .toList(),
        ),
        ...measurements.asMap().entries.map((entry) {
          final i  = entry.key;
          final m  = entry.value;
          final sc = _statusColor(m.status);
          final bg = i.isEven ? _rowAlt : PdfColors.white;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Container(
                  width: 20,
                  height: 20,
                  decoration: pw.BoxDecoration(
                    color: sc,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Center(
                    child: pw.Text(m.code,
                        style: pw.TextStyle(
                          fontSize: 6.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        )),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                child: pw.Text(m.label,
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _textDark,
                    )),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                child: pw.Text(m.finding,
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      color: _textMid,
                      lineSpacing: 1.3,
                    )),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6, vertical: 6),
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 5, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: sc,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '${m.angleDeg.toStringAsFixed(1)}°',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildIssuesList(List<String> problems) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _boxBorder),
        borderRadius: pw.BorderRadius.circular(4),
        color: const PdfColor.fromInt(0xFFFFF8F8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: problems.asMap().entries.map((e) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${e.key + 1}.',
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFFC62828),
                    )),
                pw.SizedBox(width: 6),
                pw.Text(e.value,
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      color: _textDark,
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static pw.Widget _buildScoreRow(PostureReport report) {
    final counts = [
      (
      'Good',
      report.measurements.where((m) => m.status == 'good').length,
      const PdfColor.fromInt(0xFF2E7D32)
      ),
      (
      'Mild',
      report.measurements.where((m) => m.status == 'mild').length,
      const PdfColor.fromInt(0xFFFFA000)
      ),
      (
      'Moderate',
      report.measurements.where((m) => m.status == 'moderate').length,
      const PdfColor.fromInt(0xFFF57C00)
      ),
      (
      'Severe',
      report.measurements.where((m) => m.status == 'severe').length,
      const PdfColor.fromInt(0xFFC62828)
      ),
    ];
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: counts.map((c) {
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6),
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            decoration: pw.BoxDecoration(
              color: c.$3,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Column(
              children: [
                pw.Text('${c.$2}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    )),
                pw.Text(c.$1,
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.white,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  static pw.Widget _buildExercisesTable(
      List<ExerciseSuggestion> exercises)
  {
    pw.Widget hCell(String t) => pw.Container(
      padding: const pw.EdgeInsets.symmetric(
          horizontal: 8, vertical: 7),
      child: pw.Text(t,
          style: pw.TextStyle(
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
            color: _tableHeader,
          )),
    );

    return pw.Table(
      border: pw.TableBorder(
        bottom: const pw.BorderSide(color: _divider, width: 0.6),
        horizontalInside:
        const pw.BorderSide(color: _divider, width: 0.5),
      ),
      columnWidths: const {
        0: pw.FlexColumnWidth(0.6),
        1: pw.FlexColumnWidth(2.4),
        2: pw.FlexColumnWidth(4.6),
        3: pw.FlexColumnWidth(0.8),
        4: pw.FlexColumnWidth(1.6),
      },
      children: [
        pw.TableRow(children: [
          hCell('S.No'),
          hCell('Exercise'),
          hCell('Description & Tip'),
          hCell('Sets'),
          hCell('Reps'),
        ]),
        // Cyan separator line
        pw.TableRow(
          children: List.generate(
            5,
                (_) => pw.Container(height: 1.2, color: _cyan),
          ),
        ),
        ...exercises.asMap().entries.map((entry) {
          final i  = entry.key;
          final ex = entry.value;
          final bg = i.isEven ? _rowAlt : PdfColors.white;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${i + 1}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: _textMid,
                    )),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                child: pw.Text(ex.name,
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _cyan,
                    )),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 6),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(ex.description,
                        style: pw.TextStyle(
                          fontSize: 8.2,
                          color: _textMid,
                          lineSpacing: 1.3,
                        )),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFFFFFDE7),
                        border: pw.Border.all(
                          color: const PdfColor.fromInt(0xFFFFE082),
                          width: 0.6,
                        ),
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text('Tip: ${ex.tip}',
                          style: pw.TextStyle(
                            fontSize: 7.8,
                            color: _textDark,
                          )),
                    ),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(ex.sets,
                    style: pw.TextStyle(
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      color: _textDark,
                    )),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                child: pw.Text(ex.reps,
                    style: pw.TextStyle(
                      fontSize: 8.2,
                      color: _textMid,
                    )),
              ),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTotalBar(PostureReport report) {
    final good  = report.measurements
        .where((m) => m.status == 'good')
        .length;
    final total = report.measurements.length;
    final pct   = total > 0 ? ((good / total) * 100).round() : 0;

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 280,
          decoration: pw.BoxDecoration(
            color: _totalBg,
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: pw.Text(
                  'POSTURE SCORE',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      '$good / $total Good',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      '$pct%  ·  ${_overallText(report.overallStatus)}',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      padding:
      const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'This is a computer generated report. No signature required.',
            style: pw.TextStyle(fontSize: 7.5, color: _textLight),
          ),
          pw.Text(
            'www.zeromedixine.com',
            style: pw.TextStyle(
              fontSize: 7.5,
              color: _cyan,
              decoration: pw.TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> sharePdf(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "Your ZEROMEDIXINE Posture Report",
    );
  }
}
