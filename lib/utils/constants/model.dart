import 'dart:convert';

import 'package:flutterquiz/utils/ImageApi_Model.dart';
import 'package:http/http.dart' as http;

Future<ApiResponse> fetchData() async {
  final response = await http.post(Uri.parse('https://quiz.destov.com/Api/get_sliders'));
 print(response.body);
  print(response.statusCode);
  if (response.statusCode == 200) {
    print("Api is sucessfully integrated ");
    final Map<String, dynamic> jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    
    return ApiResponse.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load data');
  }
}
