import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage>
    with TickerProviderStateMixin {
  final TextEditingController _cityController =
      TextEditingController(text: "תל אביב");
  
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;
  String? _errorMessage;
  
 
  static const String _apiKey = "75e9831b5a72b701c986769c9bc69520";
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
  
    _searchWeather();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _searchWeather() async {
    if (_cityController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final city = _cityController.text.trim();
   
      String cityQuery = city;
      if (city == "תל אביב" || city == "תל-אביב") {
        cityQuery = "Tel Aviv,IL"; 
      } else if (city == "ירושלים") {
        cityQuery = "Jerusalem,IL";
      } else if (city == "חיפה") {
        cityQuery = "Haifa,IL";
      }
      
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityQuery&appid=$_apiKey&units=metric&lang=he'
      );
      
      final response = await http.get(url);
      
      print('API URL: $url'); 
      print('Response status: ${response.statusCode}'); 
      print('Response body: ${response.body}'); 
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
        _animationController.reset();
        _animationController.forward();
      } else {
        setState(() {
          _errorMessage = 'לא נמצאה עיר בשם זה';
          _isLoading = false;
          _weatherData = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'שגיאה בחיבור לאינטרנט';
        _isLoading = false;
        _weatherData = null;
      });
    }
  }

  IconData _getWeatherIcon(String? condition) {
    if (condition == null) return Icons.wb_sunny;
    
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') || conditionLower.contains('sun')) {
      return Icons.wb_sunny;
    } else if (conditionLower.contains('cloud')) {
      return Icons.cloud;
    } else if (conditionLower.contains('rain') || conditionLower.contains('drizzle')) {
      return Icons.grain;
    } else if (conditionLower.contains('snow')) {
      return Icons.ac_unit;
    } else if (conditionLower.contains('thunder')) {
      return Icons.flash_on;
    } else if (conditionLower.contains('mist') || conditionLower.contains('fog')) {
      return Icons.blur_on;
    }
    return Icons.wb_cloudy;
  }

  Color _getWeatherColor(String? condition) {
    if (condition == null) return Colors.orange;
    
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') || conditionLower.contains('sun')) {
      return Colors.orange;
    } else if (conditionLower.contains('cloud')) {
      return Colors.blueGrey;
    } else if (conditionLower.contains('rain') || conditionLower.contains('drizzle')) {
      return Colors.blue;
    } else if (conditionLower.contains('snow')) {
      return Colors.lightBlue;
    } else if (conditionLower.contains('thunder')) {
      return Colors.deepPurple;
    }
    return Colors.grey;
  }

  LinearGradient _getBackgroundGradient(String? condition) {
    if (condition == null) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.orange.shade200, Colors.orange.shade50],
      );
    }
    
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('clear') || conditionLower.contains('sun')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.orange.shade200, Colors.yellow.shade50],
      );
    } else if (conditionLower.contains('rain') || conditionLower.contains('drizzle')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue.shade300, Colors.blue.shade50],
      );
    } else if (conditionLower.contains('cloud')) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blueGrey.shade200, Colors.blueGrey.shade50],
      );
    }
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.teal.shade200, Colors.teal.shade50],
    );
  }

  @override
  Widget build(BuildContext context) {
    final condition = _weatherData?['weather']?[0]?['main'];
    
    return Container(
      decoration: BoxDecoration(
        gradient: _getBackgroundGradient(condition),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
               
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.teal.shade600,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'חיפוש מזג אוויר',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cityController,
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                hintText: 'הזן שם עיר...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.teal.shade600,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _searchWeather(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal.shade400,
                                  Colors.teal.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _searchWeather,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'חפש',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

           
                Expanded(
                  child: _buildWeatherDisplay(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    if (_errorMessage != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red.shade600,
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_weatherData == null) {
      return const Center(
        child: Text(
          'הזן שם עיר לחיפוש מזג האוויר',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final cityName = _weatherData!['name'];
    final temperature = _weatherData!['main']['temp'].round();
    final description = _weatherData!['weather'][0]['description'];
    final feelsLike = _weatherData!['main']['feels_like'].round();
    final humidity = _weatherData!['main']['humidity'];
    final windSpeed = _weatherData!['wind']['speed'];
    final condition = _weatherData!['weather'][0]['main'];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
          
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                
                    Text(
                      cityName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
          
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getWeatherColor(condition).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _getWeatherIcon(condition),
                            size: 80,
                            color: _getWeatherColor(condition),
                          ),
                        ),
                        const SizedBox(width: 30),
                        Column(
                          children: [
                            Text(
                              '${temperature}°',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w300,
                                color: _getWeatherColor(condition),
                              ),
                            ),
                            Text(
                              'צלזיוס',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                   
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _getWeatherColor(condition).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _getWeatherColor(condition),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
            
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'פרטים נוספים',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildWeatherDetail(
                            Icons.thermostat,
                            'מרגיש כמו',
                            '${feelsLike}°C',
                            Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: _buildWeatherDetail(
                            Icons.water_drop,
                            'לחות',
                            '${humidity}%',
                            Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: _buildWeatherDetail(
                            Icons.air,
                            'רוח',
                            '${windSpeed} מ/ש',
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}