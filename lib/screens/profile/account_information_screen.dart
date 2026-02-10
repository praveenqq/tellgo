// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:tellgo_app/bloc/auth/auth_bloc.dart';
// import 'package:tellgo_app/bloc/auth/auth_state.dart';
// import 'package:tellgo_app/theme/app_theme.dart';

// class AccountInformationScreen extends StatelessWidget {
//   const AccountInformationScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppTheme.backgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: AppTheme.textPrimary,
//             size: 20,
//           ),
//           onPressed: () => context.pop(),
//         ),
//         title: Text(
//           'Account Information',
//           style: AppTheme.headingMedium.copyWith(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: BlocBuilder<AuthBloc, AuthState>(
//         builder: (context, authState) {
//           final user = authState.user;
//           final userName = user?.name ?? 'N/A';
//           final userEmail = user?.email ?? 'N/A';
//           final userPhone = user?.phoneNumber ?? 'N/A';
//           final userPhotoUrl = user?.photoUrl ?? user?.profileImageUrl;
          
//           return SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             padding: const EdgeInsets.all(AppTheme.spacing16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Profile Picture Section
//                 Center(
//                   child: Stack(
//                     children: [
//                       Container(
//                         width: 120,
//                         height: 120,
//                         decoration: BoxDecoration(
//                           color: AppTheme.surfaceColor,
//                           shape: BoxShape.circle,
//                         ),
//                         child: userPhotoUrl != null && userPhotoUrl.isNotEmpty
//                             ? ClipOval(
//                                 child: Image.network(
//                                   userPhotoUrl,
//                                   width: 120,
//                                   height: 120,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return const Icon(
//                                       Icons.person,
//                                       size: 60,
//                                       color: AppTheme.textSecondary,
//                                     );
//                                   },
//                                 ),
//                               )
//                             : const Icon(
//                                 Icons.person,
//                                 size: 60,
//                                 color: AppTheme.textSecondary,
//                               ),
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: Container(
//                           width: 36,
//                           height: 36,
//                           decoration: const BoxDecoration(
//                             color: AppTheme.primaryPurple,
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.add,
//                             color: AppTheme.textOnPrimary,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: AppTheme.spacing32),
//                 // Account Details
//                 _InfoRow(label: 'Full Name', value: userName),
//                 const SizedBox(height: AppTheme.spacing16),
//                 _InfoRow(label: 'Email', value: userEmail),
//                 const SizedBox(height: AppTheme.spacing16),
//                 _InfoRow(label: 'Phone Number', value: userPhone),
//                 const SizedBox(height: AppTheme.spacing16),
//                 _InfoRow(
//                   label: 'Email Verified',
//                   value: user?.emailVerified == true ? 'Yes' : 'No',
//                 ),
//                 const SizedBox(height: AppTheme.spacing32),
//                 // Edit Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // TODO: Navigate to edit screen
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppTheme.primaryPurple,
//                       padding: const EdgeInsets.symmetric(
//                         vertical: AppTheme.spacing16,
//                       ),
//                     ),
//                     child: Text(
//                       'Edit Profile',
//                       style: AppTheme.button.copyWith(
//                         color: AppTheme.textOnPrimary,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _InfoRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _InfoRow({
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTheme.bodySmall.copyWith(
//             fontSize: 12,
//             color: AppTheme.textSecondary,
//           ),
//         ),
//         const SizedBox(height: AppTheme.spacing4),
//         Text(
//           value,
//           style: AppTheme.bodyLarge.copyWith(
//             fontSize: 16,
//             color: AppTheme.textPrimary,
//           ),
//         ),
//       ],
//     );
//   }
// }

