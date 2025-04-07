import 'dart:math';
import 'addresses.dart';

/// Returns a random address from the list.
Map<String, dynamic> getRandomAddress() {
  final random = Random();
  final index = random.nextInt(addressesInSector.length);
  return addressesInSector[index];
}

/// Reduces life percentage based on guess distance.
double calculateLifeReduction(double currentLife, double distance) {
  double reduction = 0.0;
  if (distance < 100) {
    reduction = 0.0;
  } else if (distance < 300) {
    reduction = 0.1;
  } else if (distance < 500) {
    reduction = 0.2;
  } else if (distance < 1000) {
    reduction = 0.3;
  } else {
    reduction = 0.5;
  }

  return (currentLife - reduction).clamp(0.0, 1.0);
}
