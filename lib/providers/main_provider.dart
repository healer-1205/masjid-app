import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mosque_donation_app/models/post_donation_info_model.dart';
import '../services/api_helper.dart';

class MainProviderClass  extends ChangeNotifier {
  bool loading = false;
  bool isSuccess = false;

  // ignore: prefer_typing_uninitialized_variables
  late var mResponse;
  ApiHelper apiHelper = ApiHelper();



  Future<void> getCategoriesResponse() async {
    loading = true;
    notifyListeners();
    http.Response response = (await apiHelper.getCategories())!;
    if (response.statusCode == 200) {
      isSuccess = true;
      mResponse = response;
    } else {
      mResponse = response;
      isSuccess = false;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> postDonationInfoResponse(ModelPostDonationInfo model) async {
    loading = true;
    notifyListeners();
    http.Response response = (await apiHelper.postDonationInfoRequest(model))!;
    if (response.statusCode == 200) {
      isSuccess = true;
      mResponse = response;
    } else {
      mResponse = response;
      isSuccess = false;
    }
    loading = false;
    notifyListeners();
  }

}