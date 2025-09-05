import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// OTP input state provider
final otpInputProvider = StateProvider<String>((ref) => '');

// Individual OTP field providers for each digit
final otpField0Provider = StateProvider<String>((ref) => '');
final otpField1Provider = StateProvider<String>((ref) => '');
final otpField2Provider = StateProvider<String>((ref) => '');
final otpField3Provider = StateProvider<String>((ref) => '');
final otpField4Provider = StateProvider<String>((ref) => '');
final otpField5Provider = StateProvider<String>((ref) => '');

// Combined OTP provider that watches all fields
final combinedOTPProvider = Provider<String>((ref) {
  final field0 = ref.watch(otpField0Provider);
  final field1 = ref.watch(otpField1Provider);
  final field2 = ref.watch(otpField2Provider);
  final field3 = ref.watch(otpField3Provider);
  final field4 = ref.watch(otpField4Provider);
  final field5 = ref.watch(otpField5Provider);

  return field0 + field1 + field2 + field3 + field4 + field5;
});

// OTP completion state provider
final otpCompletedProvider = Provider<bool>((ref) {
  final combinedOTP = ref.watch(combinedOTPProvider);
  return combinedOTP.length == 6;
});

// Helper function to get field provider by index
StateProvider<String> getOTPFieldProvider(int index) {
  switch (index) {
    case 0:
      return otpField0Provider;
    case 1:
      return otpField1Provider;
    case 2:
      return otpField2Provider;
    case 3:
      return otpField3Provider;
    case 4:
      return otpField4Provider;
    case 5:
      return otpField5Provider;
    default:
      throw ArgumentError('Invalid OTP field index: $index');
  }
}

// Action to clear all OTP fields
final clearOTPProvider = Provider<VoidCallback>((ref) {
  return () {
    ref.read(otpField0Provider.notifier).state = '';
    ref.read(otpField1Provider.notifier).state = '';
    ref.read(otpField2Provider.notifier).state = '';
    ref.read(otpField3Provider.notifier).state = '';
    ref.read(otpField4Provider.notifier).state = '';
    ref.read(otpField5Provider.notifier).state = '';
  };
});
