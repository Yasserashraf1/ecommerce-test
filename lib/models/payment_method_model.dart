class PaymentMethodModel {
  final String id;
  final String cardType;
  final String cardHolderName;
  final String cardNumber;
  final String lastFourDigits;
  final String expiryDate;
  final String cvv;
  final String? nickname;
  bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.cardType,
    required this.cardHolderName,
    required this.cardNumber,
    required this.lastFourDigits,
    required this.expiryDate,
    required this.cvv,
    this.nickname,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardType': cardType,
      'cardHolderName': cardHolderName,
      'cardNumber': cardNumber,
      'lastFourDigits': lastFourDigits,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'nickname': nickname,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      cardType: json['cardType'] ?? 'Visa',
      cardHolderName: json['cardHolderName'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      lastFourDigits: json['lastFourDigits'] ?? '',
      expiryDate: json['expiryDate'] ?? '',
      cvv: json['cvv'] ?? '',
      nickname: json['nickname'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}