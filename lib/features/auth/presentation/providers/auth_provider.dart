import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_invoice_pro/features/auth/data/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final isLoggedIn = await _repository.checkAuthStatus();
      if (isLoggedIn) {
        final user = await _repository.getUserProfile();
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.login(email, password);
      final user = await _repository.getUserProfile();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signup(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _repository.signup(name, email, password);
      final user = await _repository.getUserProfile();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _repository.logout();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
  }

  Future<void> googleLogin() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final user = await _repository.signInWithGoogle();
      
      if (user != null) {
        // Successful Google Login
        final profile = await _repository.getUserProfile();
        state = state.copyWith(status: AuthStatus.authenticated, user: profile);
      } else {
        // User canceled or error
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Google Sign In cancelled or failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // We don't necessarily need to change auth state for this, 
    // but we can set loading if we want the UI to react to global state.
    // For now, we'll just proxy the call and let the UI handle loading state locally if preferred,
    // or we could add a specific status. 
    // Given the UI has local loading state, we'll just await the repository call.
    await _repository.sendPasswordResetEmail(email);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
