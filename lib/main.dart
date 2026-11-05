import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/io_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxy Cert App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ProxyHomeScreen(),
    );
  }
}

class ProxyHomeScreen extends StatefulWidget {
  const ProxyHomeScreen({super.key});

  @override
  State<ProxyHomeScreen> createState() => _ProxyHomeScreenState();
}

class _ProxyHomeScreenState extends State<ProxyHomeScreen> {
  String _status = 'Chưa gửi yêu cầu';

  Future<IOClient> createCustomHttpClient() async {
    ByteData certData = await rootBundle.load('assets/certs/ca_cert.pem');
    SecurityContext context = SecurityContext(withTrustedRoots: false);
    context.setTrustedCertificatesBytes(certData.buffer.asUint8List());

    HttpClient httpClient = HttpClient(context: context)
      ..findProxy = (uri) {
        return 'PROXY nhabenluccuatoi.ddns.net:19696';
      }
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };

    return IOClient(httpClient);
  }

  Future<void> makeRequest() async {
    setState(() {
      _status = 'Đang gửi yêu cầu qua Proxy...';
    });

    try {
      final client = await createCustomHttpClient();
      final response = await client.get(Uri.parse('https://httpbin.org/ip'));

      setState(() {
        _status = 'Thành công (${response.statusCode}):\n${response.body}';
      });
    } catch (e) {
      setState(() {
        _status = 'Lỗi kết nối: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kết Nối Proxy Custom')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: makeRequest,
              child: const Text('Gửi Yêu Cầu Giao Thức HTTPS'),
            ),
          ],
        ),
      ),
    );
  }
}
