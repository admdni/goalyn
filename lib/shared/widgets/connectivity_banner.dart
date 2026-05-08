import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/i18n/app_localizations.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_typography.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;
  final VoidCallback? onReconnect;

  const ConnectivityBanner({
    super.key,
    required this.child,
    this.onReconnect,
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  late StreamSubscription<List<ConnectivityResult>> _sub;
  bool _isOffline = false;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (mounted) {
        setState(() {
          if (_isOffline && !offline) {
            // Just came back online
            _wasOffline = true;
            widget.onReconnect?.call();
            // Hide "back online" message after 3 seconds
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) setState(() => _wasOffline = false);
            });
          }
          _isOffline = offline;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        if (_isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: p.textTertiary,
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 14, color: p.background),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('no_connection'),
                    style: AppType.eyebrow(
                      size: 10,
                      color: p.background,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_wasOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: const Color(0xFF2E7D32),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_done_rounded, size: 14, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('back_online'),
                    style: AppType.eyebrow(
                      size: 10,
                      color: Colors.white,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(child: widget.child),
      ],
    );
  }
}
