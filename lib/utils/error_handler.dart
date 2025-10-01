import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      return _getAuthErrorMessage(error);
    } else if (error is PostgrestException) {
      return _getDatabaseErrorMessage(error);
    } else if (error is StorageException) {
      return _getStorageErrorMessage(error);
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String _getAuthErrorMessage(AuthException error) {
    switch (error.message) {
      case 'Invalid login credentials':
        return 'Invalid email or password';
      case 'Email not confirmed':
        return 'Please verify your email address';
      case 'User already registered':
        return 'This email is already registered';
      case 'Invalid email':
        return 'Please enter a valid email address';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters';
      default:
        return error.message;
    }
  }

  static String _getDatabaseErrorMessage(PostgrestException error) {
    if (error.message.contains('duplicate key')) {
      return 'This record already exists';
    } else if (error.message.contains('foreign key')) {
      return 'Cannot perform this action due to related data';
    } else if (error.message.contains('not found')) {
      return 'Record not found';
    } else if (error.message.contains('permission')) {
      return 'You don\'t have permission to perform this action';
    } else {
      return 'Database error: ${error.message}';
    }
  }

  static String _getStorageErrorMessage(StorageException error) {
    if (error.message.contains('not found')) {
      return 'File not found';
    } else if (error.message.contains('size')) {
      return 'File is too large';
    } else if (error.message.contains('permission')) {
      return 'You don\'t have permission to access this file';
    } else {
      return 'Storage error: ${error.message}';
    }
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<T?> handleAsyncOperation<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? successMessage,
    bool showLoading = false,
  }) async {
    if (showLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      final result = await operation();

      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      if (successMessage != null && context.mounted) {
        showSuccessSnackBar(context, successMessage);
      }

      return result;
    } catch (error) {
      if (showLoading && context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        showErrorSnackBar(context, error);
      }

      return null;
    }
  }
}
