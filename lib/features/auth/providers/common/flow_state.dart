import 'package:apsaratalent_mobile/core/network/api_exception.dart';

/// The state of a one-shot auth action: nothing yet, in flight, succeeded with a
/// message, or failed with one.
class FlowState {
  const FlowState({this.isLoading = false, this.error, this.message});

  const FlowState.idle() : this();
  const FlowState.loading() : this(isLoading: true);

  final bool isLoading;
  final String? error;

  /// What the API said on success, for the screen to show.
  final String? message;
}

/// Runs [action] and reports it as a [FlowState], with the API's own message on
/// failure. Returns the action's result, or null if it failed.
Future<T?> runFlow<T>(
  void Function(FlowState) emit,
  Future<T> Function() action, {
  String Function(T result)? message,
  String fallbackError = 'Something went wrong. Please try again.',
}) async {
  emit(const FlowState.loading());
  try {
    final result = await action();
    emit(FlowState(message: message?.call(result)));
    return result;
  } on ApiException catch (e) {
    emit(FlowState(error: e.message.isEmpty ? fallbackError : e.message));
    return null;
  } catch (_) {
    emit(FlowState(error: fallbackError));
    return null;
  }
}
