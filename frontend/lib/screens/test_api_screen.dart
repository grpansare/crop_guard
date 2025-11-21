import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  bool _isLoading = false;
  String _result = '';

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing connection...';
    });

    try {
      final isConnected = await ApiService.testConnection();
      setState(() {
        _result = isConnected
            ? 'Connection successful!'
            : 'Connection failed. Please check the API server.';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Connection Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'API URL: ${ApiService.baseUrl}',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _testConnection,
                  child: const Text('Test Connection'),
                ),
              const SizedBox(height: 20),
              Text(
                _result,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
