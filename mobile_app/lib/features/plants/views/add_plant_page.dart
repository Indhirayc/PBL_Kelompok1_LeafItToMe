import 'package:flutter/material.dart';

import 'plant_list_page.dart';

class AddPlantPage extends StatefulWidget {
  const AddPlantPage({super.key});

  @override
  State<AddPlantPage> createState() => _AddPlantPageState();
}

class _AddPlantPageState extends State<AddPlantPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController(text: "28 September 2026");
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _savePlant() {
    if (_formKey.currentState!.validate()) {
      final newPlant = Plant(
        id: "TMT-00${DateTime.now().millisecond}", // ID acak sederhana
        name: _nameController.text,
        location: _locationController.text,
        plantDate: _dateController.text,
        status: "Sehat",
        note: _noteController.text,
      );
      Navigator.pop(
        context,
        newPlant,
      ); // Mengirim objek kembali ke halaman utama
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Tanaman")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama tanaman",
                hintText: "Contoh: Tomat Pot Teras",
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? "Nama wajib diisi" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Lokasi tanaman",
                hintText: "Contoh: Teras depan",
              ),
              validator: (val) =>
                  val == null || val.isEmpty ? "Lokasi wajib diisi" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: "Tanggal tanam"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Catatan (opsional)",
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _savePlant,
              child: const Text("Simpan Tanaman"),
            ),
          ],
        ),
      ),
    );
  }
}
