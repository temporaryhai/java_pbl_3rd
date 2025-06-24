import 'package:flutter/material.dart';
import 'dart:async';
import 'android_bridge.dart';
import 'loading_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

// RouteResultsScreen is now a StatefulWidget to manage tabs
class RouteResultsScreen extends StatefulWidget {
  final String routeResultText;
  final String source;
  final String destination;

  const RouteResultsScreen({
    super.key,
    required this.routeResultText,
    required this.source,
    required this.destination,
  });

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  List<String> vikramRoutes = [];
  List<String> ebusRoutes = [];

  @override
  void initState() {
    super.initState();
    _parseAndFilterRoutes(widget.routeResultText);
  }

  // Function to parse the raw route string and filter by type
  void _parseAndFilterRoutes(String rawRoutes) {
    final lines = rawRoutes.split('\n');
    vikramRoutes.clear();
    ebusRoutes.clear();

    // Skip the first line which is "Found X route(s):"
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line.contains("Vikram")) {
        vikramRoutes.add(line);
      } else if (line.contains("eBus")) {
        ebusRoutes.add(line);
      }
      // Note: Any error messages from Java would also be included in routeResultText.
      // For robust filtering, Java should ideally return structured data.
    }
  }

  // Function to launch Google Maps URL
  Future<void> _launchMapsUrl(String origin, String dest) async {
    final encodedOrigin = Uri.encodeComponent(origin);
    final encodedDestination = Uri.encodeComponent(dest);
    final url = 'https://www.google.com/maps/dir/$encodedOrigin/$encodedDestination';
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map for directions.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Suggested Routes'),
          centerTitle: true,
          backgroundColor: theme.appBarTheme.backgroundColor,
          elevation: 4,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // TabBar Container with liquid glass styling
              Container(
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TabBar(
                  labelColor: theme.colorScheme.onPrimary,
                  unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: theme.colorScheme.secondary.withOpacity(0.5),
                  ),
                  // *** Added this line to remove the default divider ***
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Vikram Routes'),
                    Tab(text: 'eBus Routes'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Vikram Routes Tab Content
                    vikramRoutes.isEmpty
                        ? Center(child: Text('No Vikram routes found for this search.'))
                        : ListView.builder(
                      itemCount: vikramRoutes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          color: theme.cardColor.withOpacity(0.7),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              vikramRoutes[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // eBus Routes Tab Content
                    ebusRoutes.isEmpty
                        ? Center(child: Text('No eBus routes found for this search.'))
                        : ListView.builder(
                      itemCount: ebusRoutes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          color: theme.cardColor.withOpacity(0.7),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              ebusRoutes[index],
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchMapsUrl(widget.source, widget.destination),
                  icon: Icon(Icons.map),
                  label: Text('Open in Google Maps'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 5,
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(SmartCommuteApp());
}

class SmartCommuteApp extends StatefulWidget {
  @override
  _SmartCommuteAppState createState() => _SmartCommuteAppState();
}

class _SmartCommuteAppState extends State<SmartCommuteApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier(ThemeMode.light);

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Smart Commute',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              primary: Colors.lightBlue.shade700,
              primaryContainer: Colors.lightBlue.shade100,
              onPrimary: Colors.white,
              secondary: Colors.purple.shade300,
              onSecondary: Colors.white,
              surface: Colors.white.withOpacity(0.9),
              onSurface: Colors.grey.shade800,
              background: Colors.blue.shade50,
              onBackground: Colors.grey.shade900,
              error: Colors.red.shade700,
              onError: Colors.white,
            ),
            fontFamily: 'Segoe UI',
            scaffoldBackgroundColor: Colors.blue.shade50,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.lightBlue.shade700.withOpacity(0.9),
              foregroundColor: Colors.white,
              elevation: 8,
            ),
            cardColor: Colors.white,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.lightBlue.shade700,
              selectionColor: Colors.lightBlue.shade200.withOpacity(0.5),
              selectionHandleColor: Colors.lightBlue.shade700,
            ),
            inputDecorationTheme: InputDecorationTheme(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelStyle: TextStyle(color: Colors.grey.shade600),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              iconColor: Colors.lightBlue.shade700,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              primary: Colors.deepPurple.shade300,
              primaryContainer: Colors.deepPurple.shade900,
              onPrimary: Colors.white,
              secondary: Colors.tealAccent.shade400,
              onSecondary: Colors.black,
              surface: Colors.grey.shade800.withOpacity(0.8),
              onSurface: Colors.white70,
              background: Colors.black,
              onBackground: Colors.white,
              error: Colors.red.shade400,
              onError: Colors.black,
            ),
            fontFamily: 'Segoe UI',
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.deepPurple.shade900.withOpacity(0.8),
              foregroundColor: Colors.white,
              elevation: 8,
            ),
            cardColor: Colors.grey.shade800,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent.shade700,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 5,
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.tealAccent.shade400,
              selectionColor: Colors.tealAccent.shade400.withOpacity(0.5),
              selectionHandleColor: Colors.tealAccent.shade400,
            ),
            inputDecorationTheme: InputDecorationTheme(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelStyle: TextStyle(color: Colors.grey.shade400),
              hintStyle: TextStyle(color: Colors.grey.shade600),
              iconColor: Colors.tealAccent.shade400,
            ),
          ),
          home: SplashScreen(
            onThemeChanged: (newMode) {
              _themeMode.value = newMode;
            },
            currentThemeMode: mode,
          ),
        );
      },
    );
  }
}

// Splash Screen with theme toggle callback (optional)
class SplashScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;

  SplashScreen({this.onThemeChanged, this.currentThemeMode});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => HomeScreen(
            onThemeChanged: widget.onThemeChanged,
            currentThemeMode: widget.currentThemeMode,
          )));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _animation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Smart Commute',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Best routes for city travellings.',
                style: TextStyle(
                  fontSize: 18,
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Home Screen with Dark Mode Toggle
class HomeScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;

  HomeScreen({this.onThemeChanged, this.currentThemeMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> stops = [
    "6 Number Pulia", "Ajanta Chowk", "Aman Vihar", "Amrit Kunj", "Asthal",
    "Astley Hall", "ATS Tower", "Ballupur Chowk", "Baverly Hill Shalini School",
    "Bhel Chowk", "Dilaram Chowk", "Jakhan", "Mussoorie Diversion", "Rajpur",
    "Parade Ground", "Sahastradhara", "Raipur", "Araghar", "Prince Chowk", "Darshanlal Chowk",
    "Nehru Colony Chowk", "Rispana Pul", "Kargi Chowk", "ISBT", "Clement Town", "Saharanpur Chowk",
    "Railway Station", "Dilaram Chowk", "Survey Chowk", "Connaught Place", "Bindal Pul", "Kishan Nagar Chowk",
    "Kaulagarh", "Ballupur Chowk", "Chakrata Road", "Prem Nagar", "Seema Dwar", "Garhi Cantt",
    "Shimla Bypass", "Majra", "ITI Niranjanpur", "Sabji Mandi Chowk", "Patel Nagar Police Station",
    "Lal Pul", "PNB Patel Nagar", "Matawala Bagh", "Saharanpur Chowk", "Railway Station",
    "Prince Chowk", "Cyber Police Station", "Tehsil Chowk", "Darshan Lal Chowk", "Clock Tower",
    "Gandhi Park", "St. Joseph Academy", "Sachiwalaya", "Madhuban Hotel", "Ajanta Chowk",
    "Survey of India", "NIVH Front Gate", "Pacific Mall", "Inder Bawa Marg", "Sai Mandir", "Tehri House/GRD",
    "Raipur Chungi", "Sahastradhara Crossing", "Vikas Lok", "Nalapani Chowk", "Shiv Girdhar Nikunj",
    "Ekta Vihar", "Madhur Vihar", "Mayur Vihar", "Baverly Hill Shalini School", "Amrit Kunj",
    "Shri Durga Enclave", "SGRR", "Mandakini Vihar", "MDDA Colony", "Aman Vihar", "Touch Wood School",
    "ATS Tower", "IT Park", "Gujrara Mansingh Road", "Tibetan Colony", "Kirsali Gaon", "Kulhan Gaon",
    "Pacific Golf", "Dwara Chowk", "Maldevta Shiv Mandir", "Rajkiya Mahavidyalaya Maldevta",
    "Donali, Maldevta", "Asthal", "Kesharwala", "Hathi Khana Chowk", "Kichuwala",
    "Dobhal Chowk", "6 Number Pulia", "Kishan Bhawan", "RTI Bhawan", "Pearl Avenue Hotel",
    "Ring Road Diversion", "N.W.T College", "Kali Mandir", "DRDO", "Doon Presidency School",
    "Uttaranchal University", "Nanda ki Chowki", "Uttarakhand State Women\\'s Commission",
    "Uttarakhand Technical University", "Sudhowala", "Hill Grove School", "Jhanjra Hanuman Mandir",
    "Doon Global School Ayurveda College", "Shivalik Sansthan and Anusandhan Kendra",
    "Dhulkot Road", "Shiv Mandir Selaqui", "SIDCUL Gate 1", "Yamuna Colony Chowk"
  ];

  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentThemeMode ?? ThemeMode.light;
  }

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
    if (widget.onThemeChanged != null) {
      widget.onThemeChanged!(_themeMode);
    }
  }

  Future<void> _searchRoutes() async {
    print("🔍 Search button pressed!");

    final source = _sourceController.text.trim();
    final destination = _destinationController.text.trim();

    if (source.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both source and destination'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (_, __, ___) => const LoadingScreen(),
      ),
    );

    try {
      final String routeResult = await AndroidBridge.computeRoute(source, destination);
      print("📦 Java result: $routeResult");

      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RouteResultsScreen(
            routeResultText: routeResult,
            source: source,
            destination: destination,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      print("⚠️ Error from Java: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to compute route: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAutocompleteField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
  }) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: theme.cardColor.withOpacity(0.7),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return stops.where((stop) => stop
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            controller.text = selection;
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            if (controller.text != textEditingController.text) {
              textEditingController.text = controller.text;
              textEditingController.selection = controller.selection;
            }
            textEditingController.addListener(() {
              if (textEditingController.text != controller.text) {
                controller.text = textEditingController.text;
                controller.selection = textEditingController.selection;
              }
            });

            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
                icon: Icon(Icons.place, color: theme.inputDecorationTheme.iconColor),
                labelStyle: theme.inputDecorationTheme.labelStyle,
                hintStyle: theme.inputDecorationTheme.hintStyle,
              ),
              enabled: enabled,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(child: Divider(thickness: 1, color: theme.colorScheme.onBackground.withOpacity(0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Enter your SOURCE and DESTINATION",
            style: TextStyle(
                color: theme.colorScheme.onBackground.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ),
        Expanded(child: Divider(thickness: 1, color: theme.colorScheme.onBackground.withOpacity(0.3))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Smart Commute'),
        actions: [
          IconButton(
            tooltip: _themeMode == ThemeMode.light
                ? 'Switch to Dark Mode'
                : 'Switch to Light Mode',
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: child.key == ValueKey('icon1')
                      ? Tween<double>(begin: 0.75, end: 1).animate(animation)
                      : Tween<double>(begin: 1, end: 0.75).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _themeMode == ThemeMode.light
                  ? Icon(Icons.dark_mode, key: ValueKey('icon1'))
                  : Icon(Icons.light_mode, key: ValueKey('icon2')),
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        Expanded(child: Divider(thickness: 2, color: theme.colorScheme.primary.withOpacity(0.5))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "Plan Your Commute",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(thickness: 2, color: theme.colorScheme.primary.withOpacity(0.5))),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.directions_bus, size: 60, color: theme.colorScheme.secondary),
                        SizedBox(height: 10),
                        Text(
                          "Find the quickest public transport routes!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onBackground.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSeparator(),
                  SizedBox(height: 20),
                  _buildAutocompleteField(
                      label: 'Source',
                      controller: _sourceController,
                      enabled: true),
                  _buildAutocompleteField(
                      label: 'Destination',
                      controller: _destinationController,
                      enabled: true),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _searchRoutes,
                child: Text('Search Routes'),
                style: theme.elevatedButtonTheme.style,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Row(
              children: [
                Expanded(child: Divider(thickness: 2, color: theme.colorScheme.primary.withOpacity(0.5))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Powered by: Real Time Data - Dehradun",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Expanded(child: Divider(thickness: 2, color: theme.colorScheme.primary.withOpacity(0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
