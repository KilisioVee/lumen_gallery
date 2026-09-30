import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../widgets/corridor_painter_widget.dart';
import '../widgets/panel_widget.dart';
import '../widgets/projected_art_widget.dart';
import 'art_page.dart';
import 'art_preview_page.dart';
import 'camera_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  StreamSubscription<dynamic>? _gyroSub;

  double _position = 0, _targetPosition = 0;
  double _yaw = 0, _targetYaw = 0;
  double _pitch = 0, _targetPitch = 0;
  double _tiltYaw = 0, _tiltPitch = 0;
  Duration? _previous;
  DateTime? _lastGyro;

  bool _guide = true;
  bool _tiltEnabled = true;
  bool _invertTilt = false;

  static const double _maxYaw = math.pi / 2; // -90..+90 = 180 degrees.

  double get _viewYaw => (_yaw + _tiltYaw).clamp(-_maxYaw, _maxYaw);
  double get _viewPitch => (_pitch + _tiltPitch).clamp(-0.18, 0.18);

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) {
      final dt = _previous == null
          ? 0.016
          : ((elapsed - _previous!).inMicroseconds / 1000000).clamp(0.0, 0.05);
      _previous = elapsed;

      final tiltActive = _tiltYaw.abs() + _tiltPitch.abs() > 0.0005;
      final difference = (_position - _targetPosition).abs() +
          (_yaw - _targetYaw).abs() +
          (_pitch - _targetPitch).abs();

      if (difference < 0.0001 && !tiltActive) return;

      final blend = 1 - math.exp(-dt * 9);
      final decay = math.exp(-dt * 0.9);

      setState(() {
        _position += (_targetPosition - _position) * blend;
        _yaw += (_targetYaw - _yaw) * blend;
        _pitch += (_targetPitch - _pitch) * blend;
        _tiltYaw *= decay;
        _tiltPitch *= decay;
      });
    })..start();

    _startTilt();
  }

  void _startTilt() {
    _gyroSub?.cancel();

    _gyroSub = gyroscopeEvents.listen(
          (event) {
        if (!_tiltEnabled) return;

        final now = DateTime.now();
        final last = _lastGyro;
        _lastGyro = now;
        if (last == null) return;

        final dt =
        (now.difference(last).inMicroseconds / 1000000).clamp(0.0, 0.05);

        final double rawY = (event.y as num).toDouble();
        final double rawX = (event.x as num).toDouble();
        if (!rawY.isFinite || !rawX.isFinite) return;

        var turnRate = rawY.abs() < 0.12 ? 0.0 : rawY;
        final lookRate = rawX.abs() < 0.12 ? 0.0 : rawX;
        if (_invertTilt) turnRate = -turnRate;

        _tiltYaw = (_tiltYaw - turnRate * dt * 1.3).clamp(-1.2, 1.2);
        _tiltPitch = (_tiltPitch - lookRate * dt * 0.08).clamp(-0.12, 0.12);
      },
      onError: (_) {
        if (mounted) setState(() => _tiltEnabled = false);
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _gyroSub?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  void _move(double amount) => setState(() {
    _targetPosition = (_targetPosition + amount).clamp(0.0, 22.0);
    _guide = false;
  });

  void _turn(double amount) => setState(() {
    _targetYaw = (_targetYaw + amount).clamp(-_maxYaw, _maxYaw);
    _guide = false;
  });

  void _open(Art art) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFCF6),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 180,
              height: 220,
              child: CustomPaint(painter: ArtPreview(art)),
            ),
            const SizedBox(height: 22),
            Text(art.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(art.artist, style: const TextStyle(color: Color(0xFF876443))),
            const SizedBox(height: 12),
            Chip(label: Text(art.medium)),
            const SizedBox(height: 12),
            Text(art.description,
                textAlign: TextAlign.center, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Return to gallery'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final degrees = (_viewYaw * 180 / math.pi).round();

    return Scaffold(
      body: SizedBox.expand(
        child: LayoutBuilder(builder: (context, constraints) {
          final screenSize = Size(
            constraints.hasBoundedWidth
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width,
            constraints.hasBoundedHeight
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height,
          );

          final camera = Camera(screenSize, _position, _viewYaw, _viewPitch);
          final paintings = visibleArt(camera);

          return Stack(fit: StackFit.expand, children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  if (details.delta.dx.abs() > details.delta.dy.abs()) {
                    _turn(details.delta.dx * 0.006);
                  } else {
                    _move(-details.delta.dy * 0.025);
                  }
                },
                onTapUp: (details) {
                  for (final painting in paintings.reversed) {
                    if (polygon(painting.points)
                        .contains(details.localPosition)) {
                      _open(painting.art);
                      break;
                    }
                  }
                },
                child: CustomPaint(
                  size: screenSize,
                  painter: CorridorPainter(camera, paintings),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    const Panel(
                      child: Padding(
                        padding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(children: [
                          Icon(Icons.account_balance_outlined, size: 22),
                          SizedBox(width: 10),
                          Text('GALLERIE WALK',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1)),
                        ]),
                      ),
                    ),
                    const Spacer(),
                    _button(
                      _tiltEnabled
                          ? Icons.screen_rotation
                          : Icons.screen_lock_rotation,
                      _tiltEnabled ? 'Tilt view on' : 'Tilt view off',
                          () => setState(() {
                        _tiltEnabled = !_tiltEnabled;
                        _lastGyro = null;
                        _tiltYaw = 0;
                        _tiltPitch = 0;
                        if (_tiltEnabled) _startTilt();
                      }),
                      primary: _tiltEnabled,
                    ),
                    const SizedBox(width: 8),
                    _button(Icons.swap_horiz, 'Reverse tilt direction',
                            () => setState(() => _invertTilt = !_invertTilt)),
                    const SizedBox(width: 8),
                    _button(Icons.info_outline, 'Show instructions',
                            () => setState(() => _guide = !_guide)),
                  ]),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_guide)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Panel(
                        child: Padding(
                          padding: EdgeInsets.all(14),
                          child: Text(
                            'Swipe up or down to walk. Turn your phone, or swipe sideways, to look around. Tap a painting to explore it.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  Panel(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Row(children: [
                          const Icon(Icons.panorama_horizontal_outlined,
                              size: 19),
                          Expanded(
                            child: Slider(
                              value: _targetYaw,
                              min: -_maxYaw,
                              max: _maxYaw,
                              onChanged: (value) => setState(() {
                                _targetYaw = value;
                                _guide = false;
                              }),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Text('$degrees°',
                                textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 12)),
                          ),
                        ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _button(Icons.chevron_left, 'Look left',
                                    () => _turn(-math.pi / 8)),
                            _button(Icons.arrow_downward, 'Walk backward',
                                    () => _move(-1.2)),
                            _button(Icons.arrow_upward, 'Walk forward',
                                    () => _move(1.2),
                                primary: true),
                            _button(Icons.chevron_right, 'Look right',
                                    () => _turn(math.pi / 8)),
                            _button(
                                Icons.center_focus_strong,
                                'Face forward',
                                    () => setState(() {
                                  _targetYaw = 0;
                                  _targetPitch = 0;
                                  _tiltYaw = 0;
                                  _tiltPitch = 0;
                                })),
                          ],
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 10),
                ]),
              ),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _button(IconData icon, String label, VoidCallback action,
      {bool primary = false}) =>
      IconButton.filledTonal(
        tooltip: label,
        onPressed: action,
        style: IconButton.styleFrom(
          backgroundColor:
          primary ? const Color(0xFF876443) : const Color(0xFFF5F0E7),
          foregroundColor: primary ? Colors.white : const Color(0xFF514334),
        ),
        icon: Icon(icon),
      );
}