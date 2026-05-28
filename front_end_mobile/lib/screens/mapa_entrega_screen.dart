import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryMapScreen extends StatefulWidget {
  final String customerName;

  const DeliveryMapScreen({super.key, required this.customerName});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late LatLng _storeLocation;
  late LatLng _customerLocation;
  late String _trafficCondition;
  late Color _trafficColor;
  late int _estimatedTime;

  @override
  void initState() {
    super.initState();

    final random = Random();
    _storeLocation = const LatLng(-23.2825, -46.7441);

    final latOffset = (random.nextDouble() - 0.5) * 0.03;
    final lngOffset = (random.nextDouble() - 0.5) * 0.03;
    _customerLocation = LatLng(
      _storeLocation.latitude + latOffset,
      _storeLocation.longitude + lngOffset,
    );

    final trafficData = [
      {'status': 'Trânsito Fluido', 'color': const Color(0xFF00A082)},
      {'status': 'Trânsito Moderado', 'color': const Color(0xFFFF7A00)},
      {'status': 'Trânsito Intenso', 'color': const Color(0xFFEA1D2C)},
    ];

    final selectedTraffic = trafficData[random.nextInt(3)];
    _trafficCondition = selectedTraffic['status'] as String;
    _trafficColor = selectedTraffic['color'] as Color;

    _estimatedTime = 12 + random.nextInt(25);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildMarker(IconData icon, Color color, Color bgColor, double size) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: color, size: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Logística de Entrega',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                (_storeLocation.latitude + _customerLocation.latitude) / 2,
                (_storeLocation.longitude + _customerLocation.longitude) / 2,
              ),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.pizzariamodestia.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_storeLocation, _customerLocation],
                    strokeWidth: 4.0,
                    color: _trafficColor.withOpacity(0.7),
                  ),
                ],
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final currentLat = lerpDouble(
                    _storeLocation.latitude,
                    _customerLocation.latitude,
                    _animation.value,
                  )!;
                  final currentLng = lerpDouble(
                    _storeLocation.longitude,
                    _customerLocation.longitude,
                    _animation.value,
                  )!;

                  return MarkerLayer(
                    markers: [
                      Marker(
                        point: _storeLocation,
                        width: 50,
                        height: 50,
                        child: buildMarker(
                          Icons.storefront_rounded,
                          const Color(0xFF1A1A1A),
                          Colors.white,
                          24,
                        ),
                      ),
                      Marker(
                        point: _customerLocation,
                        width: 50,
                        height: 50,
                        child: buildMarker(
                          Icons.home_work_rounded,
                          const Color(0xFF1A1A1A),
                          Colors.white,
                          24,
                        ),
                      ),
                      Marker(
                        point: LatLng(currentLat, currentLng),
                        width: 64,
                        height: 64,
                        child: buildMarker(
                          Icons.sports_motorsports_rounded,
                          Colors.white,
                          const Color(0xFFEA1D2C),
                          30,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.person_pin_circle_rounded,
                          color: Color(0xFF1A1A1A),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Destino: ${widget.customerName}',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: const Color(0xFF1A1A1A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: _trafficColor,
                                  size: 10,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _trafficCondition,
                                  style: TextStyle(
                                    color: _trafficColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Divider(color: Color(0xFFF0F0F0), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Previsão de Chegada',
                            style: TextStyle(
                              color: Color(0xFF717171),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '~ $_estimatedTime min',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA1D2C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Em Rota',
                          style: TextStyle(
                            color: Color(0xFFEA1D2C),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
