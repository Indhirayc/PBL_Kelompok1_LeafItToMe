import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/main_bottom_navigation.dart';
import '../models/plant.dart';
import '../providers/plant_provider.dart';

class EditPlantPage extends ConsumerStatefulWidget {
  final String plantId;

  const EditPlantPage({super.key, required this.plantId});

  @override
  ConsumerState<EditPlantPage> createState() => _EditPlantPageState();
}

class _EditPlantPageState extends ConsumerState<EditPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isSaving = false;
  bool _isInitialized = false;
  bool _imageRemoved = false;
  File? _selectedImage;
  String? _existingImagePath;
  final ImagePicker _picker = ImagePicker();

  static String _formatDate(DateTime date) {
    const months = [
      "Januari",
      "Februari",
      "Maret",
      "April",
      "Mei",
      "Juni",
      "Juli",
      "Agustus",
      "September",
      "Oktober",
      "November",
      "Desember",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  void _initFields(Plant plant) {
    if (_isInitialized) return;
    _nameController.text = plant.name;
    _locationController.text = plant.location;
    _dateController.text = plant.plantedDate;
    _noteController.text = plant.note ?? '';
    _existingImagePath = plant.imagePath;
    if (plant.imagePath != null && File(plant.imagePath!).existsSync()) {
      _selectedImage = File(plant.imagePath!);
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _selectedImage = File(file.path);
          _imageRemoved = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal memilih gambar: $e');
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        final hasImage = !_imageRemoved &&
            (_selectedImage != null ||
                (_existingImagePath != null &&
                    _existingImagePath!.isNotEmpty));

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto Profil Tanaman',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3826),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: const Text('Ambil Foto dengan Kamera'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  title: const Text('Pilih dari Galeri'),
                  onTap: () {
                    Navigator.pop(modalContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (hasImage)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                    title: const Text(
                      'Hapus Foto',
                      style: TextStyle(color: Color(0xFFD32F2F)),
                    ),
                    onTap: () {
                      Navigator.pop(modalContext);
                      setState(() {
                        _selectedImage = null;
                        _existingImagePath = null;
                        _imageRemoved = true;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges(Plant currentPlant) async {
    if (_isSaving || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);

    final String? finalImagePath = _imageRemoved
        ? null
        : (_selectedImage?.path ?? _existingImagePath);

    final updatedPlant = Plant(
      id: currentPlant.id,
      userId: currentPlant.userId,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      plantedDate: _dateController.text.trim(),
      lastInspectionDate: currentPlant.lastInspectionDate,
      status: currentPlant.status,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      imagePath: finalImagePath,
    );

    try {
      await ref.read(plantProvider.notifier).updatePlant(updatedPlant);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil tanaman berhasil diperbarui.'),
            backgroundColor: Color(0xFF1B5E20),
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed('plant-detail', pathParameters: {'plantId': widget.plantId});
        }
      }
    } catch (error, stackTrace) {
      debugPrint('Gagal memperbarui tanaman: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui tanaman: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plant = ref.watch(plantByIdProvider(widget.plantId));

    if (plant == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1F3826),
              size: 20,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed('plants');
              }
            },
          ),
          title: const Text(
            'Edit Profil Tanaman',
            style: TextStyle(
              color: Color(0xFF1F3826),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Data tanaman tidak ditemukan.',
            style: TextStyle(color: Color(0xFF75857B), fontSize: 14),
          ),
        ),
      );
    }

    _initFields(plant);

    final ImageProvider? avatarImage = _selectedImage != null
        ? FileImage(_selectedImage!)
        : (!_imageRemoved &&
                _existingImagePath != null &&
                File(_existingImagePath!).existsSync())
            ? FileImage(File(_existingImagePath!))
            : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F3826),
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('plant-detail', pathParameters: {'plantId': widget.plantId});
            }
          },
        ),
        title: const Text(
          "Edit Profil Tanaman",
          style: TextStyle(
            color: Color(0xFF1F3826),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: AppContentLayout(
        maxWidth: 700,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Photo Selector Tanaman
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImagePickerModal,
                      child: Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF5EE),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFC8E6C9),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: avatarImage != null
                                  ? Image(
                                      image: avatarImage,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                        child: Icon(
                                          Icons.spa_rounded,
                                          color: Color(0xFF2F7D4A),
                                          size: 42,
                                        ),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.spa_rounded,
                                        color: Color(0xFF2F7D4A),
                                        size: 42,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F7D4A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showImagePickerModal,
                      child: Text(
                        avatarImage != null
                            ? 'Ubah Foto Tanaman'
                            : 'Tambah Foto Tanaman',
                        style: const TextStyle(
                          color: Color(0xFF2F7D4A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Field Nama Tanaman
              const Text(
                "Nama tanaman",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3826),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Contoh: Tomat Pot Teras",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1B5E20),
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Field Lokasi Tanaman
              const Text(
                "Lokasi tanaman",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3826),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: "Contoh: Teras depan",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1B5E20),
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Lokasi wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // Field Tanggal Tanam
              const Text(
                "Tanggal tanam",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3826),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  hintText: "Pilih tanggal tanam",
                  suffixIcon: const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF2F7D4A),
                    size: 20,
                  ),
                  hintStyle: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1B5E20),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Field Catatan (opsional)
              const Text(
                "Catatan (opsional)",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F3826),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Tambahkan informasi tanaman",
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF1B5E20),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan Perubahan
              AppButton(
                key: const Key('saveEditPlantButton'),
                label: _isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                onPressed: _isSaving ? null : () => _saveChanges(plant),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MainBottomNavigation(currentIndex: 2),
    );
  }
}
