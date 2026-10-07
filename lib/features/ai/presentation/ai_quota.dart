import 'package:apsaratalent_mobile/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apsaratalent_mobile/core/network/network_providers.dart';
import 'package:apsaratalent_mobile/features/auth/providers/session/auth_session_notifier.dart';
import 'package:apsaratalent_mobile/features/ai/data/ai_repository.dart';

final aiRepositoryProvider =
    Provider((ref) => AiRepository(ref.watch(apiClientProvider)));
final aiQuotaProvider = FutureProvider.autoDispose<AiQuota>((ref) {
  ref.watch(authSessionProvider.select((s) => s.valueOrNull?.user?.id));
  return ref.watch(aiRepositoryProvider).quota();
});

Future<T> runAiRequest<T>(WidgetRef ref, Future<T> Function() action,
    {bool cvGeneration = false}) async {
  final repository = ref.read(aiRepositoryProvider);
  try {
    return await repository.run(action, cvGeneration: cvGeneration);
  } finally {
    if (ref.context.mounted) ref.invalidate(aiQuotaProvider);
  }
}

class AiQuotaPanel extends ConsumerWidget {
  const AiQuotaPanel({super.key, this.cvGeneration = false});
  final bool cvGeneration;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usage = ref.watch(aiQuotaProvider);
    return usage.when(
      loading: () => Text(context.tr('Checking AI allowance…')),
      error: (_, __) => Row(children: [
        Expanded(
            child: Text(
                context.tr('AI allowance unavailable. Retry to check usage.'))),
        TextButton(
            onPressed: () => ref.invalidate(aiQuotaProvider),
            child: Text(context.tr('Retry'))),
      ]),
      data: (q) {
        final local = q.resetsAt.toLocal();
        final expired = DateTime.now().isAfter(q.resetsAt);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: Text(expired
                  ? context
                      .tr('AI allowance reset. Refresh to see current usage.')
                  : '${context.tr('{0} of {1} AI requests remaining today', {
                          '0': q.remaining,
                          '1': q.limit
                        })}'
                      '${cvGeneration ? '\n${context.tr('{0} of {1} CV generations remaining', {
                              '0': q.cvRemaining,
                              '1': q.cvLimit
                            })}' : ''}'
                      '\n${context.tr('Resets {0} (local time)', {
                          '0': local.toString().substring(0, 16)
                        })}')),
          IconButton(
              tooltip: context.tr('Refresh AI allowance'),
              onPressed: () => ref.invalidate(aiQuotaProvider),
              icon: const Icon(Icons.refresh)),
        ]);
      },
    );
  }
}
