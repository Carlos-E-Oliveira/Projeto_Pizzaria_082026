import '../models/pedido_model.dart';
import '../models/analytics_data.dart';

class AnalyticsService {
  static AnalyticsData processOrders(List<Pedido> orders) {
    if (orders.isEmpty) {
      return AnalyticsData(
        totalRevenue: 0,
        totalOrders: 0,
        averageTicket: 0,
        revenueByHour: {},
        paymentMethods: {},
        topProducts: {},
        ordersByCity: {},
        ordersByStatus: {},
        smartInsights: [],
        activeOrders: 0,
        completionRate: 0,
      );
    }

    double totalRevenue = 0.0;
    Map<int, double> hourly = {};
    Map<String, int> payments = {'PIX': 0, 'Cartão': 0, 'Dinheiro': 0};
    Map<String, int> products = {};
    Map<String, int> cities = {};
    Map<OrderStatus, int> statuses = {
      OrderStatus.preparing: 0,
      OrderStatus.delivering: 0,
      OrderStatus.delivered: 0,
    };

    final productRegex = RegExp(r'(\d+)x\s+(.+)');

    for (var order in orders) {
      totalRevenue += order.total;

      try {
        DateTime date = DateTime.parse(order.dataPedido);
        hourly[date.hour] = (hourly[date.hour] ?? 0.0) + order.total;
      } catch (_) {}

      String method = order.formaPagamento.toUpperCase();
      if (method.contains('PIX')) {
        payments['PIX'] = (payments['PIX'] ?? 0) + 1;
      } else if (method.contains('CART')) {
        payments['Cartão'] = (payments['Cartão'] ?? 0) + 1;
      } else {
        payments['Dinheiro'] = (payments['Dinheiro'] ?? 0) + 1;
      }

      cities[order.cidade] = (cities[order.cidade] ?? 0) + 1;

      if (order.status == "Em preparo") {
        statuses[OrderStatus.preparing] =
            (statuses[OrderStatus.preparing] ?? 0) + 1;
      } else if (order.status == "Saiu para entrega") {
        statuses[OrderStatus.delivering] =
            (statuses[OrderStatus.delivering] ?? 0) + 1;
      } else if (order.status == "Entregue") {
        statuses[OrderStatus.delivered] =
            (statuses[OrderStatus.delivered] ?? 0) + 1;
      }

      List<String> items = order.pedido.split(RegExp(r'\r?\n'));
      for (var item in items) {
        final match = productRegex.firstMatch(item.trim());
        if (match != null && match.groupCount >= 2) {
          int qty = int.tryParse(match.group(1)!) ?? 1;
          String name = match
              .group(2)!
              .split('-')[0]
              .replaceAll(RegExp(r'\(.*?\)'), '')
              .trim();
          products[name] = (products[name] ?? 0) + qty;
        }
      }
    }

    var sortedCities = cities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    Map<String, int> topCities = Map.fromEntries(sortedCities.take(4));

    var sortedProducts = products.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    Map<String, int> topProds = Map.fromEntries(sortedProducts.take(4));

    var sortedHourly = hourly.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    Map<int, double> finalHourly = Map.fromEntries(sortedHourly);

    List<String> insights = [];
    int activeOrders =
        (statuses[OrderStatus.preparing] ?? 0) +
        (statuses[OrderStatus.delivering] ?? 0);
    int deliveredOrders = statuses[OrderStatus.delivered] ?? 0;
    double completionRate = (deliveredOrders / orders.length) * 100;

    String topPayment = payments.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    double paymentPct = (payments[topPayment]! / orders.length) * 100;
    insights.add(
      "O método $topPayment representa ${paymentPct.toStringAsFixed(1)}% do volume de transações.",
    );

    if (topCities.isNotEmpty) {
      String mainCity = topCities.keys.first;
      double cityPct = (topCities[mainCity]! / orders.length) * 100;
      insights.add(
        "A cidade de $mainCity concentra ${cityPct.toStringAsFixed(1)}% da demanda operacional.",
      );
    }

    if (topProds.isNotEmpty) {
      String mainProd = topProds.keys.first;
      insights.add(
        "O item $mainProd possui a maior representatividade em vendas.",
      );
    }

    if (finalHourly.isNotEmpty) {
      int peak = finalHourly.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      insights.add(
        "Maior concentração de faturamento observada na faixa das ${peak}h.",
      );
    }

    return AnalyticsData(
      totalRevenue: totalRevenue,
      totalOrders: orders.length,
      averageTicket: orders.isNotEmpty ? totalRevenue / orders.length : 0.0,
      revenueByHour: finalHourly,
      paymentMethods: payments,
      topProducts: topProds,
      ordersByCity: topCities,
      ordersByStatus: statuses,
      smartInsights: insights,
      activeOrders: activeOrders,
      completionRate: completionRate,
    );
  }
}
