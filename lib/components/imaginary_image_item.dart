// // // lib/components/imaginary_image_item.dart
// import 'package:flutter/material.dart';
// import 'dart:typed_data';
//
// class _MarkerWidget extends StatelessWidget {
//   final Uint8List imageData;
//   final int favoriteCnt;
//
//   const _MarkerWidget({
//     required this.imageData,
//     required this.favoriteCnt,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 80,
//       height: 80,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.25),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.memory(
//               imageData,
//               width: 80,
//               height: 80,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned(
//             bottom: 6,
//             right: 6,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.black54,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.favorite, color: Colors.red, size: 13),
//                   const SizedBox(width: 2),
//                   Text(
//                     '$favoriteCnt',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
// // import 'package:cached_network_image/cached_network_image.dart';
// //
// // class ImaginaryImageItem extends StatelessWidget {
// //   final String imageUrl;
// //   final int favoriteCnt;
// //
// //   const ImaginaryImageItem({
// //     super.key,
// //     required this.imageUrl,
// //     required this.favoriteCnt,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: 80,
// //       height: 80,
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.25),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Stack(
// //         children: [
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(12),
// //             child: CachedNetworkImage(
// //               imageUrl: imageUrl,
// //               width: 80,
// //               height: 80,
// //               fit: BoxFit.cover,
// //               placeholder: (context, url) => Container(
// //                 color: Colors.grey[300],
// //                 child: const Center(
// //                   child: CircularProgressIndicator(strokeWidth: 2),
// //                 ),
// //               ),
// //               errorWidget: (context, url, error) => Container(
// //                 color: Colors.grey[300],
// //                 child: const Icon(Icons.error, color: Colors.grey),
// //               ),
// //             ),
// //           ),
// //           Positioned(
// //             bottom: 6,
// //             right: 6,
// //             child: Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
// //               decoration: BoxDecoration(
// //                 color: Colors.black54,
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   const Icon(Icons.favorite, color: Colors.red, size: 13),
// //                   const SizedBox(width: 2),
// //                   Text(
// //                     '$favoriteCnt',
// //                     style: const TextStyle(
// //                       fontSize: 12,
// //                       fontWeight: FontWeight.w500,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }