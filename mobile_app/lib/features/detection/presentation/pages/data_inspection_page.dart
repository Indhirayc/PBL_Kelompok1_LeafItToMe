import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_page_header.dart';

class InspectionPlant {
  const InspectionPlant({
    required this.name,
    required this.id,
    required this.location,
  });

  final String name;
  final String id;
  final String location;
}

class InspectionDraft {
  const InspectionDraft({
    required this.plant,
    required this.inspectionDate,
    required this.note,
  });

  final InspectionPlant plant;
  final DateTime inspectionDate;
  final String note;
}

class DataInspectionPage extends StatefulWidget {
  const DataInspectionPage({
    super.key,
    this.plant = const InspectionPlant(
      name: 'Tomat Pot Depan',
      id: 'TMT-001',
      location: 'Teras depan',
    ),
  });

  final InspectionPlant plant;

  @override
  State<DataInspectionPage> createState() => _DataInspectionPageState();
}

class _DataInspectionPageState extends State<DataInspectionPage> {
  static const Color _background = Color(0xFFFBFCF9);
  static const Color _darkGreen = Color(0xFF183E2D);
  static const Color _primaryGreen = Color(0xFF1F7338);
  static const Color _secondaryText = Color(0xFF718478);
  static const Color _border = Color(0xFFDDE5DF);
  static const Color _plantCard = Color(0xFFE8F6E7);

  final TextEditingController _noteController = TextEditingController();
  DateTime _inspectionDate = DateTime.now();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectInspectionDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _inspectionDate,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _inspectionDate = selectedDate;
    });
  }

  void _continueToPhotoSelection() {
    context.pushNamed(
      'photo-source',
      extra: InspectionDraft(
        plant: widget.plant,
        inspectionDate: _inspectionDate,
        note: _noteController.text.trim(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            AppPageHeader(
              title: 'Data Pemeriksaan',
              subtitle: 'Lengkapi data sebelum memindai daun.',
              showBackButton: true,
              onBack: context.pop,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlantCard(),
                    const SizedBox(height: 22),
                    _buildDateField(),
                    const SizedBox(height: 18),
                    _buildNoteField(),
                    const SizedBox(height: 18),
                    _buildInformationNotice(),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        key: const Key('continueToPhotoButton'),
                        onPressed: _continueToPhotoSelection,
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                        label: const Text('Lanjut Pilih Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _plantCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFD5EFCB),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: _primaryGreen,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plant.name,
                  style: const TextStyle(
                    color: _darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.plant.id}  •  ${widget.plant.location}',
                  style: const TextStyle(color: _secondaryText, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal pemeriksaan',
          style: TextStyle(
            color: _darkGreen,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            key: const Key('inspectionDateField'),
            onTap: _selectInspectionDate,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDate(_inspectionDate),
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: _primaryGreen,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan tambahan (opsional)',
          style: TextStyle(
            color: _darkGreen,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('inspectionNoteField'),
          controller: _noteController,
          minLines: 3,
          maxLines: 4,
          maxLength: 300,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Tuliskan kondisi tanaman',
            hintStyle: const TextStyle(color: _secondaryText, fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            counterStyle: const TextStyle(color: _secondaryText, fontSize: 10),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInformationNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2C4),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF94701A), size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tanggal dan catatan akan menyertai data pemeriksaan ini.',
              style: TextStyle(
                color: Color(0xFF715815),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
