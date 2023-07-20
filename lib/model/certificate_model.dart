class Certificate {
  String id;
  String campaignId;
  String certificateUrl;

  Certificate({
    required this.id,
    required this.campaignId,
    required this.certificateUrl,
  });

  factory Certificate.fromMap(Map<String, dynamic> map) {
    return Certificate(
      id: map['id'],
      campaignId: map['campaignId'],
      certificateUrl: map['certificateUrl'],
    );
  }

  // Add this method
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'campaignId': campaignId,
      'certificateUrl': certificateUrl,
    };
  }
}
