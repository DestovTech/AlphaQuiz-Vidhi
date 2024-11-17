// class ApiResponse {
//   final bool error;
//   final Data data;

//   ApiResponse({required this.error, required this.data});

//   factory ApiResponse.fromJson(Map<String, dynamic> json) {
//     return ApiResponse(
//       error: json['error'] == true || json['error'] == 1, // Safely cast to bool
//       data: Data.fromJson(json['data'] as Map<String, dynamic>), // Explicit casting
//     );
//   }
// }

// class Data {
//   final String section1Heading;
//   final List<String> section1Images;
//   final List<String> section1Descriptions;

//   Data({
//     required this.section1Heading,
//     required this.section1Images,
//     required this.section1Descriptions,
//   });

//   factory Data.fromJson(Map<String, dynamic> json) {
//     return Data(
//       section1Heading: json['section1_heading'] as String? ?? '', // Default value
//       section1Images: [
//         json['section1_image1'] as String? ?? '',
//         json['section1_image2'] as String? ?? '',
//         json['section1_image3'] as String? ?? '',
//       ],
//       section1Descriptions: [
//         json['section1_desc1'] as String? ?? '',
//         json['section1_desc2'] as String? ?? '',
//         json['section1_desc3'] as String? ?? '',
//       ],
//     );
//   }
// }





class ApiResponse {
  final bool error;
  final List<ImageData> data; // Change data type to a list of ImageData

  ApiResponse({required this.error, required this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      error: json['error'] == true || json['error'] == 1, // Safely cast to bool
      data: (json['data'] as List<dynamic>)
          .map((item) => ImageData.fromJson(item as Map<String, dynamic>))
          .toList(), // Parse list of ImageData
    );
  }
}

class ImageData {
  final String id;
  final String languageId;
  final String image;
  final String title;
  final String description;

  ImageData({
    required this.id,
    required this.languageId,
    required this.image,
    required this.title,
    required this.description,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'] as String? ?? '',
      languageId: json['language_id'] as String? ?? '',
      image: json['image'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}
