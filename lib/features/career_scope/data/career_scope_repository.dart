import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/api_exception.dart';

class CareerScope {
  const CareerScope({required this.name, this.description});
  final String name;
  final String? description;
  factory CareerScope.fromJson(Map<String, dynamic> json) => CareerScope(
        name: '${json['name'] ?? ''}'.trim(),
        description: json['description'] as String?,
      );
}

class CareerScopeRepository {
  CareerScopeRepository(this.client);
  final ApiClient client;

  Future<List<CareerScope>> all() async {
    final data = (await client.get('/public/user/career-scopes')).data;
    if (data is! List) {
      throw ApiException(message: 'Career scopes could not be loaded.');
    }
    final scopes = data
        .whereType<Map>()
        .map((e) => CareerScope.fromJson(e.cast<String, dynamic>()))
        .where((e) => e.name.isNotEmpty)
        .toList();
    if (scopes.isEmpty) {
      throw ApiException(message: 'No career scopes are available yet.');
    }
    return scopes;
  }
}
