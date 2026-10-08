import 'package:apsaratalent_mobile/core/network/api_client.dart';
import 'package:apsaratalent_mobile/core/network/generated/gateway_api.dart';
import 'package:apsaratalent_mobile/features/feed/domain/repositories/feed_repository.dart';

class DashboardRepository {
  DashboardRepository(ApiClient client) : api = GatewayApi(client);
  final GatewayApi api;
  Future<ApiMatchingAnalyticsResponseDTO> fetch(FeedViewer viewer) async {
    final response = await api.jobMatchingControllerGetMatchingAnalytics(
        id: viewer.profileId, query: {'role': viewer.role.name});
    return ApiMatchingAnalyticsResponseDTO.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }
}
