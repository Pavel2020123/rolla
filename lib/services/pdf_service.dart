import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static Future<void> generateAndShareTrainingPdf({
    required String title,
    required DateTime date,
    required String? time,
    required String location,
    required List<Map<String, String>> athletes,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    color: PdfColor.fromHex('2563EB'),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'ROLLA',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('2563EB'),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Lista de Asistencia',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColor.fromHex('6B7280'),
                ),
              ),
              pw.Divider(thickness: 1, color: PdfColor.fromHex('E5E7EB')),
              pw.SizedBox(height: 16),
              pw.Text(
                'Entrenamiento: $title',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Fecha: ${date.day}/${date.month}/${date.year} ${time ?? ''}'),
              pw.Text('Lugar: $location'),
              pw.Text('Total deportistas: ${athletes.length}'),
              pw.SizedBox(height: 24),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('2563EB'),
                ),
                rowDecoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColor.fromHex('E5E7EB')),
                  ),
                ),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                },
                headers: ['#', 'Deportista', 'Estado'],
                data: athletes.asMap().entries.map((e) {
                  final index = e.key + 1;
                  final name = e.value['name']!;
                  final status = e.value['status']!;
                  String statusLabel;
                  switch (status) {
                    case 'confirmed':
                      statusLabel = 'Confirmó';
                      break;
                    case 'declined':
                      statusLabel = 'No va';
                      break;
                    default:
                      statusLabel = 'Sin responder';
                  }
                  return [index.toString(), name, statusLabel];
                }).toList(),
              ),
              pw.SizedBox(height: 32),
              pw.Text(
                'Generado por Rolla',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('9CA3AF'),
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final safeTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final file = File('${output.path}/asistencia_$safeTitle.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Lista de asistencia - $title',
    );
  }

  static Future<void> generateAndShareEventPdf({
    required String title,
    required DateTime date,
    required String location,
    required double price,
    required List<Map<String, String>> athletes,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    color: PdfColor.fromHex('2563EB'),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'ROLLA',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('2563EB'),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Lista de Inscritos',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColor.fromHex('6B7280'),
                ),
              ),
              pw.Divider(thickness: 1, color: PdfColor.fromHex('E5E7EB')),
              pw.SizedBox(height: 16),
              pw.Text(
                'Evento: $title',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Fecha: ${date.day}/${date.month}/${date.year}'),
              pw.Text('Lugar: $location'),
              pw.Text('Precio: \$${price.toStringAsFixed(0)}'),
              pw.Text('Total deportistas: ${athletes.length}'),
              pw.SizedBox(height: 24),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('2563EB'),
                ),
                rowDecoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColor.fromHex('E5E7EB')),
                  ),
                ),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                },
                headers: ['#', 'Deportista', 'Pago', 'Habilitado'],
                data: athletes.asMap().entries.map((e) {
                  final index = e.key + 1;
                  final name = e.value['name']!;
                  final payment = e.value['payment']!;
                  final enabled = e.value['enabled']!;
                  return [
                    index.toString(),
                    name,
                    payment == 'yes' ? 'Pagado' : 'Pendiente',
                    enabled == 'yes' ? 'Sí' : 'No',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 32),
              pw.Text(
                'Generado por Rolla',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColor.fromHex('9CA3AF'),
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final safeTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
    final file = File('${output.path}/inscritos_$safeTitle.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Lista de inscritos - $title',
    );
  }
}