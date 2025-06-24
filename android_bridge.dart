import 'package:flutter/services.dart';

class AndroidBridge {
  // CORRECTED: Ensure this channel name exactly matches MainActivity.java
  static const MethodChannel _channel = MethodChannel('com.example.smart_commute_fix/route');

  // Removed the redundant 'platform' MethodChannel as '_channel' is used

  // CORRECTED: The method now returns Future<String> as Java's computeRoute returns String
  static Future<String> computeRoute(
      String source, String destination) async {
    try {
      final String rawResult = await _channel.invokeMethod('computeRoute', {
        'source': source,
        'destination': destination,
      });

      // Removed splitting logic, as Java side provides a single formatted string.
      return rawResult;
    } on PlatformException catch (e) {
      // Return an error string from the Dart side
      print("Failed to compute route from native code: '${e.message}'.");
      return "Error: ${e.message}";
    } catch (e) {
      // Catch any other unexpected errors
      print("An unexpected error occurred: $e");
      return "An unexpected error occurred.";
    }
  }
}
