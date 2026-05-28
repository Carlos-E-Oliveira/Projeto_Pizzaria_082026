import 'pedido_model.dart';

enum OrderStatus { preparing, delivering, delivered, unknown }

class AnalyticsData {
  final double totalRevenue;
  final int totalOrders;
  final double averageTicket;
  final Map<int, double> revenueByHour;
  final Map<String, int> paymentMethods;
  final Map<String, int> topProducts;
  final Map<String, int> ordersByCity;
  final Map<OrderStatus, int> ordersByStatus;
  final List<String> smartInsights;
  final int activeOrders;
  final double completionRate;

  AnalyticsData({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageTicket,
    required this.revenueByHour,
    required this.paymentMethods,
    required this.topProducts,
    required this.ordersByCity,
    required this.ordersByStatus,
    required this.smartInsights,
    required this.activeOrders,
    required this.completionRate,
  });
}