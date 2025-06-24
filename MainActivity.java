package com.example.smart_commute_fix; // Make sure this matches your package name

import androidx.annotation.NonNull; // Add this import for @NonNull annotation
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    // CORRECTED CHANNEL NAME: Must exactly match the Dart MethodChannel
    private static final String CHANNEL = "com.example.smart_commute_fix/route";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) { // Add @NonNull
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("computeRoute")) {
                        String source = call.argument("source");
                        String destination = call.argument("destination");

                        // Add null checks for source and destination arguments, similar to previous versions
                        if (source == null || destination == null) {
                            result.error("INVALID_ARGUMENTS", "Source or destination cannot be null", null);
                            return;
                        }

                        try {
                            // Call the Java algorithm, which returns a single String
                            String route = RouteLoader.computeRoute(source, destination);
                            result.success(route);
                        } catch (Exception e) {
                            // Handle any exceptions from RouteLoader.computeRoute
                            result.error("ROUTE_COMPUTATION_FAILED", e.getMessage(), e.toString());
                        }

                    } else {
                        result.notImplemented();
                    }
                });
    }
}
