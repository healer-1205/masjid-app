class PaymentResponse {
  final String status;
  final PaymentIntentDetails paymentIntent;

  PaymentResponse({
    required this.status,
    required this.paymentIntent,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      status: json['status'] ?? '',
      paymentIntent: PaymentIntentDetails.fromJson(json['paymentIntent']),
      // reader: Reader.fromJson(json['reader']),
    );
  }
}

class PaymentIntentDetails {
  final String id;
  final int amount;
  final String currency;
  final String clientSecret;
  final String status;
  final String? readerId;

  PaymentIntentDetails({
    required this.id,
    required this.amount,
    required this.currency,
    required this.clientSecret,
    required this.status,
    this.readerId,
  });

  factory PaymentIntentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentIntentDetails(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? '',
      clientSecret: json['client_secret'] ?? '',
      status: json['status'] ?? '',
      readerId: json['metadata']?['readerId'] ?? '', // Extract readerId safely
    );
  }
}
