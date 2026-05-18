import 'package:flutter/material.dart';
import 'dart:async';

class MockDatabaseService {
  // Singleton pattern
  static final MockDatabaseService _instance = MockDatabaseService._internal();
  factory MockDatabaseService() => _instance;
  MockDatabaseService._internal() {
    _initDefaults();
  }

  // Passenger state
  late ValueNotifier<double> walletBalance;
  late ValueNotifier<List<Map<String, dynamic>>> completedTrips;
  late ValueNotifier<List<Map<String, dynamic>>> activeBookings;

  // Driver state
  late ValueNotifier<double> driverEarnings;
  late ValueNotifier<int> driverTripsCount;
  late ValueNotifier<double> driverRating;
  late ValueNotifier<bool> isDriverOnline;
  late ValueNotifier<String> activeDriverStatus; // 'idle', 'offering', 'navigating_pickup', 'on_trip'
  late ValueNotifier<Map<String, dynamic>?> currentActiveJob;

  // Global system notification state
  late ValueNotifier<Map<String, String>?> activeNotification;

  void _initDefaults() {
    walletBalance = ValueNotifier<double>(345.50);
    
    completedTrips = ValueNotifier<List<Map<String, dynamic>>>([
      {
        'id': 'trip_1',
        'date': 'Yesterday, 17:42',
        'driver': 'Gift Ndlovu',
        'driverRating': 4.90,
        'car': 'Silver Nissan Almera',
        'cost': 'R 72.00',
        'distance': '8.2 km',
        'duration': '14 mins',
        'pickup': 'Hatfield Plaza, Hatfield',
        'dropoff': 'Union Buildings, Arcadia',
        'type': 'Wave Go',
      },
      {
        'id': 'trip_2',
        'date': '14 May 2026, 08:15',
        'driver': 'Lerato Khumalo',
        'driverRating': 4.95,
        'car': 'White Toyota Quest',
        'cost': 'R 125.00',
        'distance': '14.5 km',
        'duration': '22 mins',
        'pickup': 'Pretoria Central Station, CBD',
        'dropoff': 'Menlyn Mall, Pretoria East',
        'type': 'Wave Premium',
      },
      {
        'id': 'trip_3',
        'date': '11 May 2026, 21:30',
        'driver': 'Tshepo Mokwena',
        'driverRating': 4.82,
        'car': 'Blue VW Polo',
        'cost': 'R 55.00',
        'distance': '5.1 km',
        'duration': '9 mins',
        'pickup': 'Brooklyn Mall, Brooklyn',
        'dropoff': 'University of Pretoria, Hatfield',
        'type': 'Wave Go',
      },
    ]);

    activeBookings = ValueNotifier<List<Map<String, dynamic>>>([]);

    // Driver side
    driverEarnings = ValueNotifier<double>(420.00);
    driverTripsCount = ValueNotifier<int>(6);
    driverRating = ValueNotifier<double>(4.92);
    isDriverOnline = ValueNotifier<bool>(false);
    activeDriverStatus = ValueNotifier<String>('idle');
    currentActiveJob = ValueNotifier<Map<String, dynamic>?>(null);
    activeNotification = ValueNotifier<Map<String, String>?>(null);
  }

  // Create a new booking from the passenger side
  void createBooking({
    required String destination,
    required String rideType,
    required String price,
    required String eta,
  }) {
    final Map<String, dynamic> booking = {
      'id': 'booking_${DateTime.now().millisecondsSinceEpoch}',
      'destination': destination,
      'rideType': rideType,
      'price': price,
      'eta': eta,
      'passengerName': 'Marcus Osei-Bonsu',
      'passengerRating': 4.87,
      'pickup': 'Current Location (Pretoria Central)',
      'status': 'pending',
    };
    activeBookings.value = List.from(activeBookings.value)..add(booking);
    
    // Set the job active for matching to any online driver
    currentActiveJob.value = booking;
    activeDriverStatus.value = 'offering';
  }

  // Driver accepts booking job
  void acceptActiveJob() {
    if (currentActiveJob.value == null) return;
    
    final updatedJob = Map<String, dynamic>.from(currentActiveJob.value!);
    updatedJob['status'] = 'accepted';
    updatedJob['driverName'] = 'Sipho Dlamini';
    updatedJob['car'] = 'White Toyota Corolla';
    updatedJob['plate'] = 'GP 42 ND GP';

    currentActiveJob.value = updatedJob;
    activeDriverStatus.value = 'navigating_pickup';
  }

  // Driver starts job trip
  void startActiveJobTrip() {
    if (currentActiveJob.value == null) return;
    
    final updatedJob = Map<String, dynamic>.from(currentActiveJob.value!);
    updatedJob['status'] = 'on_trip';
    
    currentActiveJob.value = updatedJob;
    activeDriverStatus.value = 'on_trip';
  }

  // Driver completes job
  void completeActiveJob() {
    final job = currentActiveJob.value;
    if (job == null) return;

    // 1. Calculate fare amount
    String priceStr = job['price'].toString().replaceAll('R', '').replaceAll(' ', '');
    double priceVal = double.tryParse(priceStr) ?? 65.0;

    // 2. Add to driver earnings and count
    driverEarnings.value += priceVal;
    driverTripsCount.value += 1;

    // 3. Deduct from passenger wallet balance
    walletBalance.value = walletBalance.value - priceVal;

    // 4. Create completed trip record
    final newTripRecord = {
      'id': job['id'],
      'date': 'Just Now',
      'driver': job['driverName'] ?? 'Sipho Dlamini',
      'driverRating': 4.92,
      'car': job['car'] ?? 'White Toyota Corolla',
      'cost': job['price'],
      'distance': '8.2 km',
      'duration': '14 mins',
      'pickup': job['pickup'],
      'dropoff': job['destination'],
      'type': job['rideType'] == 'wave_go' ? 'Wave Go' : (job['rideType'] == 'wave_premium' ? 'Wave Premium' : 'Wave XL'),
    };

    completedTrips.value = List.from(completedTrips.value)..insert(0, newTripRecord);

    // 5. Clean up active status
    activeBookings.value = [];
    currentActiveJob.value = null;
    activeDriverStatus.value = 'idle';
  }

  // Cancel/reject job
  void cancelActiveJob() {
    activeBookings.value = [];
    currentActiveJob.value = null;
    activeDriverStatus.value = 'idle';
  }

  // Trigger a system-wide banner notification
  void triggerNotification(String title, String body, {String icon = 'notifications'}) {
    activeNotification.value = {
      'title': title,
      'body': body,
      'icon': icon,
    };
    
    // Automatically clear banner after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (activeNotification.value != null &&
          activeNotification.value!['title'] == title &&
          activeNotification.value!['body'] == body) {
        activeNotification.value = null;
      }
    });
  }
}
