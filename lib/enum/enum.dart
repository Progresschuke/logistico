import 'package:flutter/material.dart';

/// Represents the active user role in the application.
enum UserRole {
  customer,
  rider;

  bool get isCustomer => this == UserRole.customer;
  bool get isRider => this == UserRole.rider;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.rider:
        return 'Rider';
    }
  }
}

enum DeliveryStatus {
  assigned,
  inTransit,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case DeliveryStatus.assigned:
        return 'Order Assigned';
      case DeliveryStatus.inTransit:
        return 'Order In Transit';
      case DeliveryStatus.delivered:
        return 'Order Delivered';
      case DeliveryStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  Icon get icon {
    switch (this) {
      case DeliveryStatus.assigned:
        return const Icon(Icons.assignment);
      case DeliveryStatus.inTransit:
        return const Icon(Icons.delivery_dining);
      case DeliveryStatus.delivered:
        return const Icon(Icons.check_circle);
      case DeliveryStatus.cancelled:
        return const Icon(Icons.cancel);
    }
  }
}
