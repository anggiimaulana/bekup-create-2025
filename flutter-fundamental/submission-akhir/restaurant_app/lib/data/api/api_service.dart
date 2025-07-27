import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:restaurant_app/data/model/restaurant/restaurant_detail_response.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant_list_response.dart';
import 'package:restaurant_app/data/model/restaurant/restaurant_search_response.dart';

class ApiService {
  static const String _baseUrl = "https://restaurant-api.dicoding.dev";

  Future<RestaurantListResponse> getRestaurantList() async {
    try {
      final response = await http
          .get(Uri.parse("$_baseUrl/list"))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return RestaurantListResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load restaurant list.');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your connection.');
    } on TimeoutException {
      throw Exception(
        'Request to the server took too long. Please try again later.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<RestaurantDetailResponse> getRestaurantDetail(String id) async {
    try {
      final response = await http
          .get(Uri.parse("$_baseUrl/detail/$id"))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        return RestaurantDetailResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load restaurant details.');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your connection.');
    } on TimeoutException {
      throw Exception(
        'Request to the server took too long. Please try again later.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<RestaurantSearchResponse> getRestaurantSearch(String query) async {
    try {
      final response = await http
          .get(Uri.parse("$_baseUrl/search?q=$query"))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        return RestaurantSearchResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load searched restaurant list.');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your connection.');
    } on TimeoutException {
      throw Exception(
        'Request to the server took too long. Please try again later.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> addCustomerReview(String id, String name, String review) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/review'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'id': id, 'name': name, 'review': review}),
          )
          .timeout(Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (!(response.statusCode == 200 || response.statusCode == 201) ||
          data['error'] == true) {
        throw Exception('Failed to add restaurant review.');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your connection.');
    } on TimeoutException {
      throw Exception(
        'Request to the server took too long. Please try again later.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
