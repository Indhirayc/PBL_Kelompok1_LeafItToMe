import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpFaqPage extends StatefulWidget {
  const HelpFaqPage({super.key});

  @override
  State<HelpFaqPage> createState() => _HelpFaqPageState();
}

class _HelpFaqPageState extends State<HelpFaqPage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  final List<_FaqItemData> _faqItems = const [
    _FaqItemData(
      question: 'Bagaimana cara menambahkan tanaman?',
      answer:
          'Buka menu TanamanKu, kemudian tekan tombol Tambah Tanaman. '
          'Isi nama tanaman, lokasi tanaman, dan tanggal tanam. '
          'Setelah seluruh data terisi, tekan tombol Simpan.',
      keywords: ['tanaman', 'tambah tanaman', 'menambahkan', 'tanamanku'],
    ),
    _FaqItemData(
      question: 'Bagaimana cara melakukan pemeriksaan daun?',
      answer:
          'Pilih salah satu tanaman pada halaman TanamanKu. '
          'Buka fitur pemeriksaan, isi formulir pemeriksaan, kemudian '
          'ambil foto atau pilih foto daun dari galeri. Setelah itu, '
          'tekan tombol Deteksi Sekarang.',
      keywords: ['pemeriksaan', 'deteksi', 'scan', 'daun', 'foto'],
    ),
    _FaqItemData(
      question: 'Bagaimana cara mengambil foto daun yang baik?',
      answer:
          'Gunakan pencahayaan yang cukup, pastikan daun terlihat jelas, '
          'hindari gambar yang buram, dan usahakan hanya terdapat satu '
          'daun utama pada foto. Jangan mengambil foto terlalu jauh.',
      keywords: ['foto', 'kamera', 'gambar', 'daun', 'buram'],
    ),
    _FaqItemData(
      question: 'Di mana hasil pemeriksaan disimpan?',
      answer:
          'Hasil pemeriksaan disimpan pada riwayat tanaman yang dipilih. '
          'Buka menu TanamanKu, pilih tanaman, kemudian buka bagian '
          'Riwayat Pemeriksaan untuk melihat seluruh hasil sebelumnya.',
      keywords: ['hasil', 'riwayat', 'simpan', 'pemeriksaan'],
    ),
    _FaqItemData(
      question: 'Apakah aplikasi membutuhkan koneksi internet?',
      answer:
          'Ya. Koneksi internet diperlukan untuk menyimpan data tanaman '
          'dan hasil pemeriksaan ke penyimpanan cloud serta menampilkan '
          'kembali riwayat pemeriksaan pengguna.',
      keywords: ['internet', 'offline', 'online', 'koneksi', 'cloud'],
    ),
    _FaqItemData(
      question: 'Apakah hasil deteksi merupakan diagnosis pasti?',
      answer:
          'Tidak. Hasil deteksi LeafItToMe merupakan hasil klasifikasi '
          'awal berdasarkan foto daun. Gunakan hasil tersebut sebagai '
          'informasi pendukung dan lakukan pemeriksaan lebih lanjut '
          'apabila kondisi tanaman semakin memburuk.',
      keywords: ['hasil', 'diagnosis', 'penyakit', 'akurasi', 'deteksi'],
    ),
    _FaqItemData(
      question: 'Mengapa hasil pemeriksaan tidak muncul?',
      answer:
          'Pastikan perangkat terhubung ke internet, foto daun berhasil '
          'dipilih, dan seluruh formulir pemeriksaan telah diisi. '
          'Jika masalah masih terjadi, coba tutup lalu buka kembali aplikasi.',
      keywords: ['error', 'gagal', 'hasil', 'tidak muncul', 'pemeriksaan'],
    ),
    _FaqItemData(
      question: 'Bagaimana cara melihat detail riwayat pemeriksaan?',
      answer:
          'Buka menu TanamanKu dan pilih tanaman yang ingin dilihat. '
          'Pada bagian Riwayat Pemeriksaan, pilih salah satu riwayat untuk '
          'melihat tanggal, foto daun, hasil penyakit, tingkat keyakinan, '
          'dan catatan pemeriksaan.',
      keywords: ['riwayat', 'detail', 'tanamanku', 'hasil'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_FaqItemData> get _filteredFaqItems {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _faqItems;
    }

    return _faqItems.where((item) {
      final questionMatch = item.question.toLowerCase().contains(query);

      final answerMatch = item.answer.toLowerCase().contains(query);

      final keywordMatch = item.keywords.any(
        (keyword) => keyword.toLowerCase().contains(query),
      );

      return questionMatch || answerMatch || keywordMatch;
    }).toList();
  }

  void _showContactInformation() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _HelpColors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hubungi Kami',
                  style: TextStyle(
                    color: _HelpColors.darkGreen,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Jika kamu masih mengalami kendala, hubungi tim LeafItToMe.',
                  style: TextStyle(
                    color: _HelpColors.secondaryText,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                const _ContactItem(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  value: 'support@leafittome.id',
                ),
                const SizedBox(height: 12),
                const _ContactItem(
                  icon: Icons.schedule_rounded,
                  label: 'Jam layanan',
                  value: 'Senin–Jumat, 08.00–16.00',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredFaqItems;

    return Scaffold(
      backgroundColor: _HelpColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1F3826),
            size: 20,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Bantuan & FAQ',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Color(0xFF1F3826),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(27, 18, 27, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpHeader(),
              const SizedBox(height: 24),
              _buildSearchField(),
              const SizedBox(height: 28),
              const Text(
                'Pertanyaan yang Sering Diajukan',
                style: TextStyle(
                  color: _HelpColors.darkGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Temukan jawaban mengenai penggunaan LeafItToMe.',
                style: TextStyle(
                  color: _HelpColors.secondaryText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              if (filteredItems.isEmpty)
                _buildEmptySearchResult()
              else
                _buildFaqList(filteredItems),
              const SizedBox(height: 28),
              _buildContactCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF8F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          _HelpHeaderIcon(),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ada yang bisa dibantu?',
                  style: TextStyle(
                    color: _HelpColors.darkGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Cari pertanyaan atau lihat panduan penggunaan aplikasi.',
                  style: TextStyle(
                    color: _HelpColors.secondaryText,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      cursorColor: _HelpColors.primaryGreen,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      style: const TextStyle(color: _HelpColors.darkGreen, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Cari bantuan...',
        hintStyle: const TextStyle(color: Color(0xFF9AA9A0), fontSize: 14),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: _HelpColors.primaryGreen,
          size: 22,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchQuery = '';
                  });
                },
                tooltip: 'Hapus pencarian',
                icon: const Icon(
                  Icons.close_rounded,
                  color: _HelpColors.secondaryText,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: _HelpColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: _searchBorder(),
        enabledBorder: _searchBorder(),
        focusedBorder: _searchBorder(
          color: _HelpColors.primaryGreen,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _buildFaqList(List<_FaqItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: _HelpColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _HelpColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLastItem = index == items.length - 1;

          return Column(
            children: [
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  splashColor: _HelpColors.primaryGreen.withValues(alpha: 0.05),
                  highlightColor: _HelpColors.primaryGreen.withValues(
                    alpha: 0.03,
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  iconColor: _HelpColors.primaryGreen,
                  collapsedIconColor: _HelpColors.secondaryText,
                  title: Text(
                    item.question,
                    style: const TextStyle(
                      color: _HelpColors.darkGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.answer,
                        style: const TextStyle(
                          color: _HelpColors.secondaryText,
                          fontSize: 13,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLastItem)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: _HelpColors.border,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptySearchResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: _HelpColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _HelpColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: _HelpColors.secondaryText,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Bantuan tidak ditemukan',
            style: TextStyle(
              color: _HelpColors.darkGreen,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Coba gunakan kata kunci yang berbeda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _HelpColors.secondaryText, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _HelpColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _HelpColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _HelpColors.primaryGreen.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: _HelpColors.primaryGreen,
              size: 26,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Masih membutuhkan bantuan?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _HelpColors.darkGreen,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Hubungi tim LeafItToMe jika masalahmu belum terselesaikan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _HelpColors.secondaryText,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _showContactInformation,
              icon: const Icon(Icons.mail_outline_rounded, size: 19),
              label: const Text(
                'Hubungi Kami',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _HelpColors.primaryGreen,
                foregroundColor: _HelpColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _searchBorder({
    Color color = _HelpColors.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _HelpHeaderIcon extends StatelessWidget {
  const _HelpHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _HelpColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Icon(
        Icons.help_outline_rounded,
        color: _HelpColors.primaryGreen,
        size: 28,
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9F4),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _HelpColors.primaryGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: _HelpColors.primaryGreen, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _HelpColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: _HelpColors.darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItemData {
  const _FaqItemData({
    required this.question,
    required this.answer,
    required this.keywords,
  });

  final String question;
  final String answer;
  final List<String> keywords;
}

abstract final class _HelpColors {
  static const Color background = Color(0xFFFBFCF7);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryGreen = Color(0xFF2D8952);
  static const Color darkGreen = Color(0xFF123F2E);
  static const Color secondaryText = Color(0xFF74867C);
  static const Color border = Color(0xFFD7E1D9);
}
