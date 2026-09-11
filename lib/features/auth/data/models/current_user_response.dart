import 'package:apsaratalent_mobile/features/auth/domain/entities/current_user_entity.dart';
import 'package:apsaratalent_mobile/features/auth/domain/enums/user_role_enum.dart';

/// `GET /user/current-user`, parsed down to [CurrentUserEntity].
///
/// An employee carries `employee: { firstname, lastname, job, avatar }`; a
/// company carries `company: { name, industry, avatar }`. An admin has neither.
class CurrentUserResponse {
  const CurrentUserResponse._(this._json);

  factory CurrentUserResponse.fromJson(Map<String, dynamic> json) =>
      CurrentUserResponse._(json);

  final Map<String, dynamic> _json;

  CurrentUserEntity toEntity() {
    final role = EUserRole.fromString('${_json['role'] ?? 'none'}');
    final email = _nonEmpty(_json['email']);
    final employee = _json['employee'];
    final company = _json['company'];

    String? name;
    String? headline;
    String? avatar;

    if (employee is Map) {
      name = [employee['firstname'], employee['lastname']]
          .map(_nonEmpty)
          .whereType<String>()
          .join(' ');
      headline = _nonEmpty(employee['job']);
      avatar = _nonEmpty(employee['avatar']);
    } else if (company is Map) {
      name = _nonEmpty(company['name']);
      headline = _nonEmpty(company['industry']);
      avatar = _nonEmpty(company['avatar']);
    }

    return CurrentUserEntity(
      id: '${_json['id'] ?? ''}',
      role: role,
      // A profile that hasn't been filled in yet has no name; the address the
      // person signed in with is the least surprising stand-in.
      displayName: (name == null || name.isEmpty)
          ? (email ?? _nonEmpty(_json['phone']) ?? 'Your account')
          : name,
      headline: headline,
      email: email,
      avatarUrl: avatar,
    );
  }

  static String? _nonEmpty(dynamic value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
