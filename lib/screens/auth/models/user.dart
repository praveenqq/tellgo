// Domain model matching /User/login → result
import 'package:equatable/equatable.dart';

class Permission extends Equatable {
  final int? permissionId;
  final bool? canView, canCreate, canUpdate, canDelete;
  final int? permissionTaskId;
  final String? permissionTaskName;
  final int? module;

  const Permission({
    this.permissionId,
    this.canView,
    this.canCreate,
    this.canUpdate,
    this.canDelete,
    this.permissionTaskId,
    this.permissionTaskName,
    this.module,
  });

  factory Permission.fromJson(Map<String, dynamic> j) => Permission(
    permissionId: _asInt(j['permissionId']),
    canView: _asBool(j['canView']),
    canCreate: _asBool(j['canCreate']),
    canUpdate: _asBool(j['canUpdate']),
    canDelete: _asBool(j['canDelete']),
    permissionTaskId: _asInt(j['permissionTaskId']),
    permissionTaskName: j['permissionTaskName']?.toString(),
    module: _asInt(j['module']),
  );

  Map<String, dynamic> toJson() => {
    'permissionId': permissionId,
    'canView': canView,
    'canCreate': canCreate,
    'canUpdate': canUpdate,
    'canDelete': canDelete,
    'permissionTaskId': permissionTaskId,
    'permissionTaskName': permissionTaskName,
    'module': module,
  };

  @override
  List<Object?> get props => [
    permissionId,
    canView,
    canCreate,
    canUpdate,
    canDelete,
    permissionTaskId,
    permissionTaskName,
    module,
  ];
}

class User extends Equatable {
  final int? userId;
  final String? userName, emailAddress, phoneNumber, isdcode, fullName;
  final bool? isActive, isWallet;
  final int? recordStatus, createdBy, updatedBy, roleId;
  final String? accessToken, refreshToken, useridentifier, roleName;
  final DateTime? refreshTokenExpiry, createdDate, updatedDate;
  final num? balance;
  final List<Permission> permissions;

  const User({
    this.userId,
    this.userName,
    this.emailAddress,
    this.phoneNumber,
    this.isdcode,
    this.fullName,
    this.isActive,
    this.recordStatus,
    this.accessToken,
    this.refreshToken,
    this.refreshTokenExpiry,
    this.createdBy,
    this.createdDate,
    this.updatedBy,
    this.updatedDate,
    this.balance,
    this.isWallet,
    this.useridentifier,
    this.roleId,
    this.roleName,
    this.permissions = const [],
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    userId: _asInt(j['userId']),
    userName: j['userName']?.toString(),
    emailAddress: j['emailAddress']?.toString(),
    phoneNumber: j['phoneNumber']?.toString(),
    isdcode: j['isdcode']?.toString(),
    fullName: j['fullName']?.toString(),
    isActive: _asBool(j['isActive']),
    recordStatus: _asInt(j['recordStatus']),
    accessToken: j['accessToken']?.toString(),
    refreshToken: j['refreshToken']?.toString(),
    refreshTokenExpiry: _asDate(j['refreshTokenExpiry']),
    createdBy: _asInt(j['createdBy']),
    createdDate: _asDate(j['createdDate']),
    updatedBy: _asInt(j['updatedBy']),
    updatedDate: _asDate(j['updatedDate']),
    balance: _asNum(j['balance']),
    isWallet: _asBool(j['isWallet']),
    useridentifier: j['useridentifier']?.toString(),
    roleId: _asInt(j['roleId']),
    roleName: j['roleName']?.toString(),
    permissions:
        (j['permissions'] as List?)
            ?.map((e) => Permission.fromJson(Map<String, dynamic>.from(e)))
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'emailAddress': emailAddress,
    'phoneNumber': phoneNumber,
    'isdcode': isdcode,
    'fullName': fullName,
    'isActive': isActive,
    'recordStatus': recordStatus,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'refreshTokenExpiry': refreshTokenExpiry?.toIso8601String(),
    'createdBy': createdBy,
    'createdDate': createdDate?.toIso8601String(),
    'updatedBy': updatedBy,
    'updatedDate': updatedDate?.toIso8601String(),
    'balance': balance,
    'isWallet': isWallet,
    'useridentifier': useridentifier,
    'roleId': roleId,
    'roleName': roleName,
    'permissions': permissions.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    userId,
    userName,
    emailAddress,
    phoneNumber,
    isdcode,
    fullName,
    isActive,
    recordStatus,
    accessToken,
    refreshToken,
    refreshTokenExpiry,
    createdBy,
    createdDate,
    updatedBy,
    updatedDate,
    balance,
    isWallet,
    useridentifier,
    roleId,
    roleName,
    permissions,
  ];
}

// ── helpers ────────────────────────────────────────────────────────────────
int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

num? _asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  return num.tryParse(v.toString());
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().toLowerCase();
  return s == 'true' || s == '1';
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}
