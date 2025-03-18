

class ModelPostDonationInfo {
  int? amount;
  String? categoryId;
  String? paymentMethod;
  GiftAid? giftAid;

  ModelPostDonationInfo(
      {this.amount, this.categoryId, this.paymentMethod, this.giftAid});

  ModelPostDonationInfo.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    categoryId = json['categoryId'];
    paymentMethod = json['paymentMethod'];
    giftAid =
    json['giftAid'] != null ? GiftAid.fromJson(json['giftAid']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['categoryId'] = categoryId;
    data['paymentMethod'] = paymentMethod;
    if (giftAid != null) {
      data['giftAid'] = giftAid!.toJson();
    }
    return data;
  }
}

class GiftAid {
  bool? eligible;
  String? fullName;
  String? email;
  String? address;
  String? addressLine2;
  bool? ukTaxPayer;

  GiftAid(
      {this.eligible,
        this.fullName,
        this.email,
        this.address,
        this.addressLine2,
        this.ukTaxPayer});

  GiftAid.fromJson(Map<String, dynamic> json) {
    eligible = json['eligible'];
    fullName = json['fullName'];
    email = json['email'];
    address = json['address'];
    addressLine2 = json['addressLine2'];
    ukTaxPayer = json['ukTaxPayer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['eligible'] = eligible;
    data['fullName'] = fullName;
    data['email'] = email;
    data['address'] = address;
    data['addressLine2'] = addressLine2;
    data['ukTaxPayer'] = ukTaxPayer;
    return data;
  }
}
