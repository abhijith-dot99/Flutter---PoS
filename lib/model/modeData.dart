class ModeData {
  final String modeName;
  final String modeType;


  ModeData({
    required this.modeName,
    required this.modeType, 

  });

  // Convert a JSON object to an ItemData object
  factory ModeData.fromJson(Map<String, dynamic> json) {
    return ModeData(
      modeName: json['mode_name'] ?? '',
      modeType: json['mode_type'] ?? '',
    );
  }

  // Convert an ItemData object to a Map for database insertion
  Map<String, dynamic> toJson() {
    return {
      'mode_name': modeName,
      'mode_type': modeType,
    };
  }
}