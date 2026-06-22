import 'package:dio/dio.dart';

class ErrorHandler {
  static String getFriendlyErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Время ожидания подключения истекло. Пожалуйста, проверьте подключение к интернету или работу сервера.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Не удалось подключиться к серверу. Пожалуйста, убедитесь, что сервер бэкенда запущен.';
      }
      
      final data = e.response?.data;
      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('error') && data['error'] != null) {
          final errorData = data['error'];
          if (errorData is Map<String, dynamic>) {
            final code = errorData['code']?.toString();
            final message = errorData['message']?.toString();
            
            switch (code) {
              case 'USER_EXISTS':
                return 'Пользователь с такой эл. почтой уже зарегистрирован.';
              case 'INVALID_CREDENTIALS':
                return 'Неверный адрес эл. почты или пароль.';
              case 'INVALID_TOKEN':
                return 'Сессия устарела. Пожалуйста, войдите снова.';
              default:
                if (message != null) {
                  final lowerMsg = message.toLowerCase();
                  if (lowerMsg.contains('email already exists') || lowerMsg.contains('user with this email already exists')) {
                    return 'Пользователь с такой эл. почтой уже зарегистрирован.';
                  }
                  if (lowerMsg.contains('invalid email or password')) {
                    return 'Неверный адрес эл. почты или пароль.';
                  }
                }
                return message ?? 'Произошла непредвиденная ошибка на сервере.';
            }
          }
        }
        
        if (data.containsKey('errors') && data['errors'] != null) {
          final errors = data['errors'];
          if (errors is Map<String, dynamic>) {
            final errorList = <String>[];
            errors.forEach((key, value) {
              final fieldName = _translateFieldName(key);
              if (value is List) {
                errorList.add('$fieldName: ${value.map((v) => _translateValidationMessage(v.toString())).join(', ')}');
              } else {
                errorList.add('$fieldName: ${_translateValidationMessage(value.toString())}');
              }
            });
            return errorList.join('\n');
          }
        }
        
        if (data.containsKey('title') && data['title'] != null) {
          return _translateValidationMessage(data['title'].toString());
        }
      }
      
      if (e.response?.statusCode == 401) {
        return 'Пользователь не авторизован. Войдите в аккаунт.';
      } else if (e.response?.statusCode == 403) {
        return 'Доступ к этой операции запрещен.';
      } else if (e.response?.statusCode == 404) {
        return 'Запрашиваемые данные не найдены на сервере.';
      } else if (e.response?.statusCode == 500) {
        return 'Внутренняя ошибка сервера. Пожалуйста, попробуйте позже.';
      }
      
      return e.message ?? 'Произошла сетевая ошибка при запросе к серверу.';
    }
    
    return e.toString();
  }

  static String _translateFieldName(String field) {
    switch (field.toLowerCase()) {
      case 'email': return 'Эл. почта';
      case 'password': return 'Пароль';
      case 'fullname': return 'Имя и фамилия';
      case 'phone': return 'Телефон';
      case 'name': return 'Название/Имя';
      case 'species': return 'Вид питомца';
      case 'breed': return 'Порода';
      default: return field;
    }
  }

  static String _translateValidationMessage(String msg) {
    final lowerMsg = msg.toLowerCase();
    
    if (lowerMsg.contains('must not be empty') || lowerMsg.contains('is required')) {
      return 'обязательно для заполнения';
    }
    if (lowerMsg.contains('email') || lowerMsg.contains('e-mail') || lowerMsg.contains('mail')) {
      return 'должен быть корректным адресом электронной почты';
    }
    if (msg.contains('must be at least') && msg.contains('characters')) {
      final match = RegExp(r'must be at least (\d+) characters').firstMatch(msg);
      if (match != null) {
        final count = match.group(1);
        return 'должен содержать не менее $count символов';
      }
    }
    return msg;
  }
}
