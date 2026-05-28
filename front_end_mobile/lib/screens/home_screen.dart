import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/pedido_model.dart';
import '../services/api_service.dart';
import 'mapa_entrega_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  String _filter = 'Todos';
  final ApiService _api = ApiService();
  Future<List<Pedido>>? _future;

  static const _red = Color(0xFFEA1D2C);
  static const _green = Color(0xFF00A082);
  static const _orange = Color(0xFFFF7A00);
  static const _teal = Color(0xFF00BFA5);
  static const _dark = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF717171);
  static const _surface = Color(0xFFF7F8FA);

  @override
  void initState() {
    super.initState();
    _future = _api.fetchPedidos();
  }

  TextStyle _poppins({
    double size = 14,
    Color color = _dark,
    FontWeight weight = FontWeight.w600,
  }) => GoogleFonts.poppins(fontSize: size, color: color, fontWeight: weight);

  String _timeAgo(String datePedido) {
    try {
      final dt = DateTime.parse(datePedido);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
      return 'há ${diff.inHours}h';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: FutureBuilder<List<Pedido>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _red));
          }
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return Center(
              child: Text(
                'Nenhum pedido hoje.',
                style: _poppins(color: _muted),
              ),
            );
          }
          final orders = snap.data!;
          return IndexedStack(
            index: _tabIndex,
            children: [
              _buildHome(orders),
              AnalyticsScreen(ordersList: orders),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  // ─── Home ─────────────────────────────────────────────────────────────────

  Widget _buildHome(List<Pedido> orders) {
    final revenue = orders.fold(0.0, (s, o) => s + o.total);
    final activeInt = orders
        .where(
          (o) => o.status == 'Em preparo' || o.status == 'Saiu para entrega',
        )
        .length;
    final avg = orders.isEmpty ? 0.0 : revenue / orders.length;
    final delivered = orders.where((o) => o.status == 'Entregue').length;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeroHeader(revenue, orders.length)),
        SliverToBoxAdapter(child: _buildStatStrip(activeInt, avg, delivered)),
        SliverToBoxAdapter(child: _buildPaymentBar(orders, revenue)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fila de pedidos',
                  style: _poppins(size: 17, weight: FontWeight.w800),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${orders.length} total',
                    style: _poppins(
                      size: 11,
                      color: _red,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildFilterChips()),
        SliverToBoxAdapter(child: _buildOrderList(orders)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildHeroHeader(double revenue, int count) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        color: _red,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      width: 22,
                      height: 22,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.local_pizza_rounded,
                        size: 22,
                        color: _red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pizzaria Modéstia',
                    style: _poppins(
                      size: 16,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Hoje',
                      style: _poppins(
                        size: 12,
                        color: Colors.white,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Receita de hoje',
            style: _poppins(
              size: 13,
              color: Colors.white.withOpacity(0.75),
              weight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'R\$ ${revenue.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count pedidos realizados',
            style: _poppins(
              size: 13,
              color: Colors.white.withOpacity(0.75),
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatStrip(int active, double avg, int delivered) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              'Em andamento',
              '$active',
              'pedidos ativos',
              Icons.delivery_dining_rounded,
              _orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              'Ticket médio',
              'R\$ ${avg.toStringAsFixed(0)}',
              'por pedido',
              Icons.receipt_long_rounded,
              _green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              'Entregues',
              '$delivered',
              'concluídos',
              Icons.check_circle_rounded,
              _red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 10),
        Text(title, style: _poppins(size: 10, color: _muted)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: _poppins(size: 16, weight: FontWeight.w800),
          ),
        ),
        Text(sub, style: _poppins(size: 10, color: color)),
      ],
    ),
  );

  Widget _buildPaymentBar(List<Pedido> orders, double revenue) {
    if (revenue == 0) return const SizedBox.shrink();
    double pix = 0, card = 0, cash = 0;
    for (final o in orders) {
      final m = o.formaPagamento.toUpperCase();
      if (m.contains('PIX')) {
        pix += o.total;
      } else if (m.contains('CART')) {
        card += o.total;
      } else {
        cash += o.total;
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formas de pagamento',
              style: _poppins(size: 14, weight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _payItem('PIX', pix, _teal),
                _payItem('Cartão', card, _orange),
                _payItem('Dinheiro', cash, _dark),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  if (pix > 0)
                    Expanded(
                      flex: (pix / revenue * 100).round(),
                      child: Container(height: 8, color: _teal),
                    ),
                  if (card > 0)
                    Expanded(
                      flex: (card / revenue * 100).round(),
                      child: Container(height: 8, color: _orange),
                    ),
                  if (cash > 0)
                    Expanded(
                      flex: (cash / revenue * 100).round(),
                      child: Container(height: 8, color: _dark),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _payItem(String label, double value, Color color) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: _poppins(size: 11, color: _muted)),
        ],
      ),
      const SizedBox(height: 3),
      Text(
        'R\$ ${value.toStringAsFixed(0)}',
        style: _poppins(size: 14, color: color, weight: FontWeight.w800),
      ),
    ],
  );

  Widget _buildFilterChips() {
    const filters = ['Todos', 'Em preparo', 'Saiu para entrega', 'Entregue'];
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final f = filters[i];
          final selected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(f),
              labelStyle: _poppins(
                size: 12,
                color: selected ? Colors.white : _dark,
                weight: FontWeight.w600,
              ),
              selected: selected,
              selectedColor: _dark,
              backgroundColor: Colors.white,
              elevation: 0,
              pressElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? Colors.transparent
                      : Colors.grey.withOpacity(0.25),
                ),
              ),
              onSelected: (v) {
                if (v) setState(() => _filter = f);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<Pedido> orders) {
    
    final filtered = _filter == 'Todos'
        ? orders
        : orders.where((o) => o.status == _filter).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 44, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'Nenhum pedido aqui.',
                style: _poppins(size: 14, color: _muted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      itemCount: filtered.length,
      itemBuilder: (_, i) => _buildOrderCard(filtered[i]),
    );
  }

  Widget _buildOrderCard(Pedido order) {
    Color statusColor;
    IconData statusIcon;
    switch (order.status) {
      case 'Saiu para entrega':
        statusColor = _red;
        statusIcon = Icons.sports_motorsports_rounded;
        break;
      case 'Entregue':
        statusColor = _green;
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = _orange;
        statusIcon = Icons.local_fire_department_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.white,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              title: Text(
                order.nome,
                style: _poppins(size: 14, weight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      order.status,
                      style: _poppins(
                        size: 11,
                        color: statusColor,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${_timeAgo(order.dataPedido)}',
                      style: _poppins(size: 11, color: _muted),
                    ),
                  ],
                ),
              ),
              trailing: Text(
                'R\$ ${order.total.toStringAsFixed(2)}',
                style: _poppins(size: 14, weight: FontWeight.w800),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Color(0xFFF0F0F0), height: 1),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.receipt_long_rounded,
                            color: Color(0xFFCCCCCC),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.pedido.trim(),
                              style: _poppins(
                                size: 13,
                                color: _dark,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFFCCCCCC),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${order.endereco}, ${order.cidade}',
                              style: _poppins(
                                size: 12,
                                color: _muted,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildPaymentBadge(order.formaPagamento),
                      if (order.status == 'Saiu para entrega') ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DeliveryMapScreen(customerName: order.nome),
                              ),
                            ),
                            icon: const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                            ),
                            label: Text(
                              'Acompanhar entregador',
                              style: _poppins(
                                size: 13,
                                color: Colors.white,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String method) {
    final u = method.toUpperCase();
    IconData icon;
    Color color;
    String text;
    if (u.contains('PIX')) {
      icon = Icons.pix_rounded;
      color = _teal;
      text = 'Já pago · PIX';
    } else if (u.contains('CART')) {
      icon = Icons.credit_card_rounded;
      color = _orange;
      text = 'Levar maquininha';
    } else {
      icon = Icons.payments_rounded;
      color = const Color(0xFF4CAF50);
      text = 'Cobrar em dinheiro';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: _poppins(size: 12, color: color, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
          backgroundColor: Colors.white,
          selectedItemColor: _red,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.home_rounded),
              ),
              label: 'Início',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Icon(Icons.bar_chart_rounded),
              ),
              label: 'Análises',
            ),
          ],
        ),
      ),
    );
  }
}
