import 'package:flutter/material.dart';
import 'services/api_service.dart';

class ConnectionTestScreen extends StatefulWidget {
  @override
  _ConnectionTestScreenState createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String _status = 'Not tested';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
    });

    try {
      final isConnected = await ApiService.testConnection();
      setState(() {
        _status = isConnected 
          ? '✅ Connection successful!' 
          : '❌ Connection failed';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing login...';
    });

    try {
      final response = await ApiService.post('auth/signin', {
        'mobile': '9579247434',
        'password': '@Grp1234',
      });
      
      setState(() {
        _status = '✅ Login successful!\nToken: ${response['token']?.substring(0, 20)}...';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Login failed: $e';
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
      appBar: AppBar(
        title: Text('Connection Test'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'API Base URL:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(ApiService.baseUrl),
                    SizedBox(height: 16),
                    Text(
                      'Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_status),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Test Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: Text('Test Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
