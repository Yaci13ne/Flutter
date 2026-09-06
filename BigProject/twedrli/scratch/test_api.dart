import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final base = 'https://twedrliapi.linguaflo.me';
  
  print('Testing GET /messages/user/1...');
  try {
    final res1 = await http.get(Uri.parse('$base/messages/user/1'));
    print('GET /messages/user/1 -> ${res1.statusCode}');
    print('Body: ${res1.body}');
  } catch (e) {
    print('Error: $e');
  }

  print('\nTesting POST /messages...');
  try {
    final res2 = await http.post(
      Uri.parse('$base/messages'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'sender_id': 1,
        'receiver_id': 2,
        'content': 'Test message'
      }),
    );
    print('POST /messages -> ${res2.statusCode}');
    print('Body: ${res2.body}');
  } catch (e) {
    print('Error: $e');
  }
}
