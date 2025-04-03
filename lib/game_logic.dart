import 'dart:math';
import 'addresses.dart';

/// Returns a random address from the list.
Map<String, dynamic> getRandomAddress() {
  final random = Random();
  final index = random.nextInt(addressesInSector.length);
  return addressesInSector[index];
}
