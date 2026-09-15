/// Shared data model for a delivery order, used across rider and tracking screens.
class DeliveryModel {
  final String orderId;
  final String storeName;
  final bool storeVerified;
  final String riderName;
  final double riderRating;
  final int estimatedMinutes;
  final double distanceKm;
  final String etaStart;
  final String etaEnd;

  /// 0 = Order Confirmed, 1 = Preparing, 2 = Out for Delivery, 3 = Delivered
  final int currentStep;
  final String statusMessage;

  const DeliveryModel({
    required this.orderId,
    required this.storeName,
    this.storeVerified = false,
    required this.riderName,
    required this.riderRating,
    required this.estimatedMinutes,
    required this.distanceKm,
    required this.etaStart,
    required this.etaEnd,
    required this.currentStep,
    required this.statusMessage,
  });

  /// Sample data for the rider screen preview.
  static const DeliveryModel riderSample = DeliveryModel(
    orderId: 'BF12345',
    storeName: 'BillingFast Store',
    storeVerified: true,
    riderName: 'Samuel',
    riderRating: 5.0,
    estimatedMinutes: 12,
    distanceKm: 1.8,
    etaStart: '1:37PM',
    etaEnd: '1:47PM',
    currentStep: 2,
    statusMessage: 'Rider is on the way',
  );

  /// Sample data for the customer tracking screen preview.
  static const DeliveryModel trackingSample = DeliveryModel(
    orderId: 'TK98765',
    storeName: 'Tamarin Beach Store',
    storeVerified: false,
    riderName: 'Samuel',
    riderRating: 5.0,
    estimatedMinutes: 10,
    distanceKm: 2.3,
    etaStart: '1:37PM',
    etaEnd: '1:47PM',
    currentStep: 1,
    statusMessage: 'Your order is being prepared',
  );
}
