import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odc_mobile_template/business/models/user/verifyOtp.dart';
import 'package:odc_mobile_template/business/services/user/userNetworkService.dart';
import 'package:odc_mobile_template/main.dart';
import 'package:odc_mobile_template/pages/auth/verifyOtp/verifyOtpState.dart';
import 'package:odc_mobile_template/utils/http/HttpRequestException.dart';

class VerifyOtpCtrl extends StateNotifier<VerifyOtpState> {
  final userNetworkService = getIt.get<UserNetworkService>();
  Timer? _timer;
  bool _isDisposed = false;

  VerifyOtpCtrl() : super(VerifyOtpState());

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }

  Future<bool> verifyOtp(VerifyOtp otp) async {
    if (_isDisposed) return false;

    state = state.copyWith(
      isSubmited: true,
      successMessage: null,
      errorMessage: null,
    );

    try {
      await userNetworkService.verifyOtp(otp);
      if (_isDisposed) return false;

      state = state.copyWith(
        isSubmited: false,
        successMessage: 'Email vérifié avec succès',
      );
      _durationToast();
      return true;
    } on HttpRequestException catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSubmited: false,
          errorMessage: "${e.body}",
        );
        _durationToast();
      }
      return false;
    } on TimeoutException catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSubmited: false,
          errorMessage: "Erreur serveur : $e",
        );
        _durationToast();
      }
      return false;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSubmited: false,
          errorMessage: "Une erreur inattendue est survenue",
        );
        _durationToast();
      }
      return false;
    }
  }

  Future<bool> resendOtp(VerifyOtp otpResend) async {
    if (_isDisposed) return false;

    state = state.copyWith(
      isSubmited: true,
      successMessage: null,
      errorMessage: null,
    );

    try {
      await userNetworkService.resendOtp(otpResend);
      if (_isDisposed) return false;

      state = state.copyWith(
        isSubmited: false,
        successMessage: 'Un code a été renvoyé',
      );
      _durationToast();
      return true;
    } on HttpRequestException catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSubmited: false,
          errorMessage: '${e.body}',
        );
        _durationToast();
      }
      return false;
    } on TimeoutException catch (_) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSubmited: false,
          errorMessage: "Temps d'attente dépassé. Le serveur ne répond pas.",
        );
        _durationToast();
      }
      return false;
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(
          isSubmited: false,
          errorMessage: 'Une erreur inattendue est survenue',
        );
        _durationToast();
      }
      return false;
    }
  }

  void resetMessages() {
    if (!_isDisposed) {
      state = state.copyWith(
        errorMessage: null,
        successMessage: null,
      );
    }
  }

  void _durationToast() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (!_isDisposed) {
        resetMessages();
      }
    });
  }
}

final verifyOtpCtrlProvider = StateNotifierProvider<VerifyOtpCtrl, VerifyOtpState>((ref) {
  return VerifyOtpCtrl();
});