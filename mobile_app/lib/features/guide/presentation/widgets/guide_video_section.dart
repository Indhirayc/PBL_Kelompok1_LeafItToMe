import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../data/models/guide_content_model.dart';
import '../../data/guide_content_repository.dart';

class GuideVideoSection extends StatefulWidget {
  const GuideVideoSection({super.key});

  @override
  State<GuideVideoSection> createState() => _GuideVideoSectionState();
}

class _GuideVideoSectionState extends State<GuideVideoSection> {
  static const Color darkGreen = Color(0xFF183E2D);

  final GuideContentRepository _repository = GuideContentRepository();

  GuideContentModel? _guide;
  YoutubePlayerController? _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadGuide());
  }

  Future<void> _loadGuide() async {
    try {
      final items = await _repository.getGuideContents();
      if (!mounted) return;

      GuideContentModel? guide;
      for (final item in items) {
        if (item.videoUrl != null && item.videoUrl!.isNotEmpty) {
          guide = item;
          break;
        }
      }
      final videoId = guide == null ? null : _youtubeId(guide.videoUrl!);

      if (guide == null || videoId == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          playsInline: true,
          interfaceLanguage: 'id',
          captionLanguage: 'id',
          strictRelatedVideos: true,
        ),
      );

      setState(() {
        _guide = guide;
        _controller = controller;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_loading || _guide == null || controller == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Video Panduan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: darkGreen,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: YoutubePlayer(controller: controller, aspectRatio: 16 / 9),
        ),
      ],
    );
  }

  String? _youtubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isEmpty) return null;
      final id = uri.pathSegments.first;
      return id.length == 11 ? id : null;
    }

    final id = uri.queryParameters['v'];
    return id != null && id.length == 11 ? id : null;
  }
}
