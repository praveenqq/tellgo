// // lib/presentation/features/home/view/widgets/header.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';

// class Header extends StatelessWidget {
//   final double sx;
//   final VoidCallback onTapHome, onSelectCurrency, onSelectLanguage, onWhatsApp;
//   final VoidCallback onLogoTap;

//   const Header({
//     super.key,
//     required this.sx,
//     required this.onTapHome,
//     required this.onSelectCurrency,
//     required this.onSelectLanguage,
//     required this.onWhatsApp,
//     required this.onLogoTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, c) {
//         final hx = sx.clamp(0.85, 1.25);

//         final leftGroup = Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [_TellGoLogo(fontSize: 20 * hx, onTap: onLogoTap)],
//         );

//         final actionsRow = Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _OutlinePill(label: 'KWD', onTap: onSelectCurrency, sx: hx),
//             SizedBox(width: 8 * hx),
//             _OutlinePill(label: 'EN', onTap: onSelectLanguage, sx: hx),
//             SizedBox(width: 8 * hx),
//             _WhatsappSvgIcon(
//               onTap: onWhatsApp,
//               size: 36 * hx.clamp(0.75, 1.15),
//             ),
//           ],
//         );

//         return Material(
//           color: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: 12 * hx,
//               vertical: 10 * hx,
//             ),
//             child: Row(
//               children: [
//                 Flexible(
//                   fit: FlexFit.tight,
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       alignment: Alignment.centerLeft,
//                       child: leftGroup,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8 * hx),
//                 Flexible(
//                   fit: FlexFit.tight,
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: FittedBox(
//                       fit: BoxFit.scaleDown,
//                       alignment: Alignment.centerRight,
//                       child: actionsRow,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _OutlinePill extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   final double sx;
//   const _OutlinePill({
//     required this.label,
//     required this.onTap,
//     required this.sx,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 12 * sx, vertical: 7 * sx),
//           decoration: BoxDecoration(
//             color: Colors.grey[100],
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: Colors.grey[300]!),
//           ),
//           child: Text(
//             label,
//             style: GoogleFonts.poppins(
//               color: Colors.black87,
//               fontWeight: FontWeight.w700,
//               fontSize: 12 * sx,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _TellGoLogo extends StatelessWidget {
//   final double fontSize;
//   final VoidCallback? onTap;
//   const _TellGoLogo({this.fontSize = 20, this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final gradient = const LinearGradient(
//       colors: [Color(0xFF8C6AF6), Color(0xFF5B3DF0)],
//       begin: Alignment.centerLeft,
//       end: Alignment.centerRight,
//     );
//     final logoRow = Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Text(
//           'tell',
//           style: GoogleFonts.poppins(
//             fontSize: fontSize,
//             fontWeight: FontWeight.w800,
//             color: Colors.black87,
//             height: 1,
//           ),
//         ),
//         ShaderMask(
//           shaderCallback: (b) => gradient.createShader(b),
//           child: Text(
//             'go.',
//             style: GoogleFonts.poppins(
//               fontSize: fontSize,
//               fontWeight: FontWeight.w800,
//               color: Colors.black87,
//               height: 1,
//             ),
//           ),
//         ),
//       ],
//     );

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(6),
//       child: Padding(padding: const EdgeInsets.all(4), child: logoRow),
//     );
//   }
// }

// class _WhatsappSvgIcon extends StatelessWidget {
//   final VoidCallback onTap;
//   final double size;
//   const _WhatsappSvgIcon({required this.onTap, this.size = 36});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       shape: const CircleBorder(),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(
//             color: const Color(0xFF1E153B),
//             borderRadius: BorderRadius.circular(size / 2),
//             border: Border.all(color: const Color(0xFF3A2E59)),
//           ),
//           alignment: Alignment.center,
//           child: SvgPicture.asset(
//             'assets/icons/whatsapp_icon.svg',
//             width: size * 0.52,
//             height: size * 0.52,
//           ),
//         ),
//       ),
//     );
//   }
// }
