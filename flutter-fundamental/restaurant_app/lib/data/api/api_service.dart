import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:restaurant_app/data/model/restaurant_detail_response.dart';
import 'package:restaurant_app/data/model/restaurant_list_response.dart';
import 'package:restaurant_app/data/model/restaurant_search_response.dart';

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
        throw Exception('Gagal memuat daftar restoran');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda');
    } on TimeoutException {
      throw Exception('Permintaan ke server terlalu lama. Coba lagi nanti');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: $e');
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
        throw Exception('Gagal memuat detail restoran.');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda');
    } on TimeoutException {
      throw Exception('Permintaan ke server terlalu lama. Coba lagi nanti');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: $e');
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
        throw Exception('Gagal memuat daftar restoran yang dicari.');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda');
    } on TimeoutException {
      throw Exception('Permintaan ke server terlalu lama. Coba lagi nanti');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga $e');
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
        throw Exception('Gagal menambahkan review restoran.');
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa koneksi Anda');
    } on TimeoutException {
      throw Exception('Permintaan ke server terlalu lama. Coba lagi nanti');
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: $e');
    }
  }
}
