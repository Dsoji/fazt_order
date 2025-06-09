import 'dart:convert';

class ImageUploadResponse {
  String? fileUrl;

  ImageUploadResponse({this.fileUrl});

  @override
  String toString() => 'ImageUploadResponse(fileUrl: $fileUrl)';

  factory ImageUploadResponse.fromMap(Map<String, dynamic> data) {
    return ImageUploadResponse(
      fileUrl: data['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'fileUrl': fileUrl,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ImageUploadResponse].
  factory ImageUploadResponse.fromJson(String data) {
    return ImageUploadResponse.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [ImageUploadResponse] to a JSON string.
  String toJson() => json.encode(toMap());

  ImageUploadResponse copyWith({
    String? fileUrl,
  }) {
    return ImageUploadResponse(
      fileUrl: fileUrl ?? this.fileUrl,
    );
  }
}
