import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_donation_app/models/post_donation_info_model.dart';


class ApiHelper {

  String baseUrl = "https://masjid-aqsa-backend-production.up.railway.app/api/";

  Future<http.Response?> getCategories() async {
    http.Response? response;
    Map<String, String> header = {
      'content-type': 'application/json',
    };

    try {
      response = await http.get(
          Uri.parse("${baseUrl}categories"),
          headers: header);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return response;
  }

  Future<http.Response?> postDonationInfoRequest(ModelPostDonationInfo payload) async {
    http.Response? response;
    Map<String, String> header = {
      'content-type': 'application/json',
    };

    try {
      response = await http.post(
          Uri.parse("${baseUrl}donations"),
          headers: header, body: jsonEncode(payload));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return response;
  }


}