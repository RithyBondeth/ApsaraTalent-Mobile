import 'package:apsaratalent_mobile/features/auth/data/models/current_user_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('carries the employee profile id, not the user id', () {
    final user = CurrentUserResponse.fromJson({
      'id': 'user-1',
      'role': 'employee',
      'employee': {'id': 'emp-1', 'firstname': 'Sophea', 'lastname': 'Chan'},
    }).toEntity();

    expect(user.id, 'user-1');
    expect(user.profileId, 'emp-1');
  });

  test('carries the company profile id', () {
    final user = CurrentUserResponse.fromJson({
      'id': 'user-2',
      'role': 'company',
      'company': {'id': 'cmp-1', 'name': 'Sabay'},
    }).toEntity();

    expect(user.profileId, 'cmp-1');
  });

  test('has no profile id before a profile exists', () {
    final user =
        CurrentUserResponse.fromJson({'id': 'u', 'role': 'none'}).toEntity();

    expect(user.profileId, isNull);
  });
}
