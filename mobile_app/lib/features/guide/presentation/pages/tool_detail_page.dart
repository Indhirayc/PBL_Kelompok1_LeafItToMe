import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/app_content_layout.dart';
import '../../../../core/widgets/marketplace_card.dart';
import '../../data/guide_data.dart';
import '../widgets/guide_illustrations.dart';

class ToolDetailPage extends StatelessWidget {
  final ToolModel tool;

  const ToolDetailPage({super.key, required this.tool});

  static const Color primaryGreen = Color(0xFF2F7D4A);
  static const Color darkGreen = Color(0xFF183E2D);
  static const Color backgroundColor = Color(0xFFF8FAF5);
  static const Color secondaryText = Color(0xFF75857B);
  static const Color borderColor = Color(0xFFE3EAE4);
  static const Color accentGreen = Color(0xFFE8F5E9);

  Future<void> _openMarketplace(BuildContext context) async {
    final encodedKeyword = Uri.encodeComponent(tool.searchKeyword);
    final url = Uri.parse(
      'https://shopee.co.id/search?keyword=$encodedKeyword',
    );

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        _showMarketplaceError(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showMarketplaceError(context);
      }
    }
  }

  void _showMarketplaceError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tautan marketplace untuk ${tool.name} tidak dapat dibuka.',
        ),
        backgroundColor: primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
              context.goNamed('guides');
            }
          },
        ),
        title: const Text(
          'Detail Kebutuhan',
          style: TextStyle(
            color: Color(0xFF1F3826),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: AppContentLayout(
        maxWidth: 900,
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Illustration Banner
                ToolIllustration(
                  toolId: tool.id,
                  icon: tool.icon,
                  imageAssetPath: tool.imageAssetPath,
                ),
                const SizedBox(height: 18),

                // Tag & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: tool.tag == 'Wajib'
                            ? accentGreen
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tool.tag,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tool.tag == 'Wajib'
                              ? primaryGreen
                              : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  tool.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: darkGreen,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  tool.fullDescription,
                  style: const TextStyle(
                    fontSize: 13,
                    color: secondaryText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Specifications Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spesifikasi Rekomendasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: darkGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: borderColor),
                      const SizedBox(height: 8),
                      ...tool.specifications.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: darkGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Tip Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F7F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: primaryGreen.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: primaryGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          tool.tip,
                          style: const TextStyle(
                            fontSize: 12,
                            color: darkGreen,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                MarketplaceCard(
                  description:
                      'Temukan alat dan bahan yang sesuai melalui '
                      'marketplace. Periksa kembali informasi dan petunjuk '
                      'penggunaan produk sebelum membeli.',
                  onPressed: () => _openMarketplace(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
