import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pedido_model.dart';

class AnalyticsScreen extends StatefulWidget {
  final List<Pedido> ordersList;
  const AnalyticsScreen({super.key, required this.ordersList});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // ─── Cores ───────────────────────────────────────────────────────────────
  static const _red = Color(0xFFEA1D2C);
  static const _green = Color(0xFF00A082);
  static const _orange = Color(0xFFFF7A00);
  static const _teal = Color(0xFF00BFA5);
  static const _blue = Color(0xFF378ADD);
  static const _dark = Color(0xFF1A1A1A);
  static const _muted = Color(0xFF717171);
  static const _surface = Color(0xFFF7F8FA);

  // ─── Métricas ─────────────────────────────────────────────────────────────
  double get totalReceita => widget.ordersList.fold(0.0, (s, o) => s + o.total);

  double get ticketMedio =>
      widget.ordersList.isEmpty ? 0 : totalReceita / widget.ordersList.length;

  int porStatus(String s) =>
      widget.ordersList.where((o) => o.status == s).length;

  double get taxaConclusao {
    if (widget.ordersList.isEmpty) return 0;
    return porStatus('Entregue') / widget.ordersList.length * 100;
  }

  // Receita por horário — só horas com pedidos
  Map<int, double> get receitaPorHora {
    final Map<int, double> h = {};
    for (final o in widget.ordersList) {
      try {
        final dt = DateTime.parse(o.dataPedido);
        h[dt.hour] = (h[dt.hour] ?? 0) + o.total;
      } catch (_) {}
    }
    return Map.fromEntries(
      h.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  int get horarioPico {
    if (receitaPorHora.isEmpty) return 0;
    return receitaPorHora.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Totais por forma de pagamento
  Map<String, double> get totaisPagamento {
    final m = {'PIX': 0.0, 'Cartão': 0.0, 'Dinheiro': 0.0};
    for (final o in widget.ordersList) {
      final u = o.formaPagamento.toUpperCase();
      if (u.contains('PIX')) {
        m['PIX'] = m['PIX']! + o.total;
      } else if (u.contains('CART')) {
        m['Cartão'] = m['Cartão']! + o.total;
      } else {
        m['Dinheiro'] = m['Dinheiro']! + o.total;
      }
    }
    return m;
  }

  // Top produtos (quantidade pedida)
  Map<String, int> get topProdutos {
    final Map<String, int> p = {};
    for (final o in widget.ordersList) {
      final partes = o.pedido.split('x ');
      if (partes.length > 1) {
        final qty = int.tryParse(partes[0].trim()) ?? 1;
        final nome = partes[1]
            .replaceAll(RegExp(r'\(.*?\)'), '')
            .split('-')[0]
            .trim();
        p[nome] = (p[nome] ?? 0) + qty;
      }
    }
    return Map.fromEntries(
      (p.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5),
    );
  }

  // Pedidos por cidade
  Map<String, int> get pedidosPorCidade {
    final Map<String, int> c = {};
    for (final o in widget.ordersList) {
      c[o.cidade] = (c[o.cidade] ?? 0) + 1;
    }
    return Map.fromEntries(
      (c.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5),
    );
  }

  String get metodoPagamentoLider {
    int pix = 0, cartao = 0, dinheiro = 0;
    for (final o in widget.ordersList) {
      final u = o.formaPagamento.toUpperCase();
      if (u.contains('PIX'))
        pix++;
      else if (u.contains('CART'))
        cartao++;
      else
        dinheiro++;
    }
    if (pix >= cartao && pix >= dinheiro) return 'PIX';
    if (cartao >= pix && cartao >= dinheiro) return 'Cartão';
    return 'Dinheiro';
  }

  // ─── Texto / Decoração ────────────────────────────────────────────────────
  TextStyle _poppins({
    double size = 13,
    Color color = _dark,
    FontWeight weight = FontWeight.w600,
  }) => GoogleFonts.poppins(fontSize: size, color: color, fontWeight: weight);

  BoxDecoration get _cardDecor => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildCabecalho()),
            SliverToBoxAdapter(child: _buildKpis()),
            SliverToBoxAdapter(child: _buildGraficoReceita()),
            SliverToBoxAdapter(child: _buildPagamentos()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildStatusCard()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildCidadesCard()),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildGraficoProdutos()),
            SliverToBoxAdapter(child: _buildInsights()),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  // ─── Cabeçalho ────────────────────────────────────────────────────────────
  Widget _buildCabecalho() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análises',
              style: _poppins(size: 26, weight: FontWeight.w800),
            ),
            Text(
              'Visão geral do dia',
              style: _poppins(size: 13, color: _muted, weight: FontWeight.w500),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.today_rounded, color: _red, size: 14),
              const SizedBox(width: 6),
              Text('Hoje', style: _poppins(size: 12, color: _red)),
            ],
          ),
        ),
      ],
    ),
  );

  // ─── KPIs ─────────────────────────────────────────────────────────────────
  Widget _buildKpis() {
    final kpis = [
      _KpiItem(
        'Receita total',
        'R\$ ${totalReceita.toStringAsFixed(2)}',
        _green,
        Icons.account_balance_wallet_rounded,
      ),
      _KpiItem(
        'Pedidos',
        '${widget.ordersList.length}',
        _red,
        Icons.local_pizza_outlined,
      ),
      _KpiItem(
        'Ticket médio',
        'R\$ ${ticketMedio.toStringAsFixed(0)}',
        _orange,
        Icons.receipt_long_rounded,
      ),
      _KpiItem(
        'Entregues',
        '${porStatus('Entregue')}',
        _green,
        Icons.check_circle_rounded,
      ),
      _KpiItem(
        'Andamento',
        '${porStatus('Em preparo') + porStatus('Saiu para entrega')}',
        _red,
        Icons.delivery_dining_rounded,
      ),
    ];
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: kpis.length,
        itemBuilder: (_, i) => Container(
          width: 128,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kpis[i].cor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(kpis[i].icone, color: kpis[i].cor, size: 18),
              ),
              const SizedBox(height: 12),
              Text(kpis[i].label, style: _poppins(size: 10, color: _muted)),
              const SizedBox(height: 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  kpis[i].valor,
                  style: _poppins(size: 16, weight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Gráfico de receita por hora ──────────────────────────────────────────
  Widget _buildGraficoReceita() {
    final dados = receitaPorHora;
    if (dados.isEmpty) return const SizedBox.shrink();

    final spots = dados.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final maxY = dados.values.reduce((a, b) => a > b ? a : b) * 1.35;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: _cardDecor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Receita por horário',
                  style: _poppins(size: 15, weight: FontWeight.w700),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Pico: ${horarioPico}h',
                    style: _poppins(
                      size: 11,
                      color: _red,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 58,
                        // Apenas 3 labels no eixo Y para não poluir
                        getTitlesWidget: (v, meta) {
                          if (v == 0) return const SizedBox.shrink();
                          // Mostra só min, meio e max aproximados
                          final vals = [
                            maxY * 0.33,
                            maxY * 0.66,
                            maxY,
                          ].map((e) => e.roundToDouble()).toList();
                          final rounded = v.roundToDouble();
                          final closest = vals.reduce(
                            (a, b) => (a - rounded).abs() < (b - rounded).abs()
                                ? a
                                : b,
                          );
                          if ((closest - rounded).abs() > maxY * 0.05)
                            return const SizedBox.shrink();
                          final label = v >= 1000
                              ? 'R\$${(v / 1000).toStringAsFixed(1)}k'
                              : 'R\$${v.toInt()}';
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              label,
                              style: _poppins(
                                size: 9,
                                color: _muted,
                                weight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (v, _) => Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${v.toInt()}h',
                            style: _poppins(
                              size: 9,
                              color: _muted,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: _red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (s, _, __, ___) => FlDotCirclePainter(
                          radius: 3,
                          color: _red,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [_red.withOpacity(0.15), Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
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

  // ─── Pagamentos ───────────────────────────────────────────────────────────
  Widget _buildPagamentos() {
    final pay = totaisPagamento;
    final t = totalReceita;
    if (t == 0) return const SizedBox.shrink();

    final cores = [_teal, _orange, _dark];
    final entradas = pay.entries.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: _cardDecor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Formas de pagamento',
              style: _poppins(size: 15, weight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            // Barra empilhada
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: List.generate(entradas.length, (i) {
                  final pct = entradas[i].value / t;
                  return Expanded(
                    flex: (pct * 1000).toInt(),
                    child: Container(height: 10, color: cores[i]),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(entradas.length, (i) {
                final pct = (entradas[i].value / t * 100);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cores[i],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entradas[i].key,
                          style: _poppins(size: 11, color: _muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${entradas[i].value.toStringAsFixed(0)}',
                      style: _poppins(
                        size: 14,
                        color: cores[i],
                        weight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}% do total',
                      style: _poppins(
                        size: 10,
                        color: _muted,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Status ───────────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    final statuses = [
      _StatusItem('Em preparo', porStatus('Em preparo'), _orange),
      _StatusItem('Saiu p/ entrega', porStatus('Saiu para entrega'), _red),
      _StatusItem('Entregue', porStatus('Entregue'), _green),
    ];
    final total = widget.ordersList.length;

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(top: 16),
      decoration: _cardDecor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status', style: _poppins(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...statuses.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.label, style: _poppins(size: 11, color: _muted)),
                      Text(
                        '${s.count}',
                        style: _poppins(size: 12, color: s.cor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : s.count / total,
                      backgroundColor: s.cor.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(s.cor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Taxa de conclusão: ${taxaConclusao.toStringAsFixed(0)}%',
            style: _poppins(size: 11, color: _green),
          ),
        ],
      ),
    );
  }

  // ─── Cidades ──────────────────────────────────────────────────────────────
  Widget _buildCidadesCard() {
    final cidades = pedidosPorCidade;
    final maxVal = cidades.values.isEmpty ? 1 : cidades.values.first;

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(top: 16),
      decoration: _cardDecor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cidades', style: _poppins(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...cidades.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          style: _poppins(size: 11, color: _muted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${e.value}',
                        style: _poppins(size: 12, color: _blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / maxVal,
                      backgroundColor: _blue.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation(_blue),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Gráfico de produtos ──────────────────────────────────────────────────
  Widget _buildGraficoProdutos() {
    final produtos = topProdutos;
    if (produtos.isEmpty) return const SizedBox.shrink();

    final nomes = produtos.keys.toList();
    final maxVal = produtos.values.first.toDouble();

    final barGroups = List.generate(nomes.length, (i) {
      final opacidade = 1.0 - (i * 0.14);
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: produtos[nomes[i]]!.toDouble(),
            color: _red.withOpacity(opacidade.clamp(0.4, 1.0)),
            width: 26,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: _cardDecor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produtos mais pedidos',
              style: _poppins(size: 15, weight: FontWeight.w700),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal * 1.35,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                        '${rod.toY.toInt()}x',
                        _poppins(size: 12, color: Colors.white),
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize:
                            60, // Aumentamos aqui para dar altura para 2 linhas de texto
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= nomes.length) return const Text('');

                          // Lógica para tratar o texto longo e evitar sobreposição
                          String nome = nomes[i];
                          // Se o nome tiver mais de 10 caracteres, truncamos ou usamos uma lógica simples
                          String display = nome.length > 10
                              ? "${nome.substring(0, 9)}.."
                              : nome;

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              display,
                              style: _poppins(
                                size: 9,
                                color: _muted,
                                weight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow
                                  .ellipsis, // Adiciona "..." se for muito longo
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Insights ─────────────────────────────────────────────────────────────
  Widget _buildInsights() {
    final pixShare = (totaisPagamento['PIX']! / totalReceita * 100)
        .toStringAsFixed(0);
    final cidadeLider = pedidosPorCidade.keys.first;
    final produtoLider = topProdutos.keys.first;

    final insights = [
      _InsightItem(
        icone: Icons.location_on_rounded,
        cor: _blue,
        texto:
            '$cidadeLider concentra a maior demanda geográfica com ${pedidosPorCidade[cidadeLider]} pedidos.',
      ),
      _InsightItem(
        icone: Icons.local_pizza_rounded,
        cor: _red,
        texto: '"$produtoLider" lidera o ranking de itens mais solicitados.',
      ),
      _InsightItem(
        icone: Icons.pix_rounded,
        cor: _teal,
        texto:
            'PIX representa $pixShare% da receita — pagamento digital consolidado.',
      ),
      _InsightItem(
        icone: Icons.schedule_rounded,
        cor: _orange,
        texto:
            'Pico de faturamento registrado às ${horarioPico}h — reforce a equipe neste período.',
      ),
      _InsightItem(
        icone: Icons.check_circle_rounded,
        cor: _green,
        texto:
            'Taxa de conclusão de ${taxaConclusao.toStringAsFixed(0)}% com ticket médio de R\$ ${ticketMedio.toStringAsFixed(2)}.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: _cardDecor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: _red, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Insights automáticos',
                  style: _poppins(size: 15, weight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: item.cor.withOpacity(0.12)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: item.cor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icone, color: item.cor, size: 15),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.texto,
                        style: _poppins(
                          size: 12,
                          color: _dark,
                          weight: FontWeight.w500,
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
}

// ─── Data classes ─────────────────────────────────────────────────────────────
class _KpiItem {
  final String label, valor;
  final Color cor;
  final IconData icone;
  const _KpiItem(this.label, this.valor, this.cor, this.icone);
}

class _StatusItem {
  final String label;
  final int count;
  final Color cor;
  const _StatusItem(this.label, this.count, this.cor);
}

class _InsightItem {
  final IconData icone;
  final Color cor;
  final String texto;
  const _InsightItem({
    required this.icone,
    required this.cor,
    required this.texto,
  });
}
