/// Modern Result type for better error handling
///
/// Bu tip, başarı ve hata durumlarını tip-güvenli bir şekilde ele alır.
/// Dart 3.0 sealed class özelliği kullanılarak pattern matching desteklenir.
///
/// Kullanım:
/// ```dart
/// final result = await repository.getData();
/// return result.when(
///   success: (data) => SuccessWidget(data),
///   failure: (error) => ErrorWidget(error),
/// );
/// ```
sealed class Result<T> {
  const Result();
}

/// Başarılı işlem sonucu
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// Başarısız işlem sonucu
class Failure<T> extends Result<T> {
  final String message;
  final ErrorType type;
  final int? statusCode;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.type = ErrorType.unknown,
    this.statusCode,
    this.originalError,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> &&
        other.message == message &&
        other.type == type &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode =>
      message.hashCode ^ type.hashCode ^ (statusCode?.hashCode ?? 0);

  @override
  String toString() =>
      'Failure(message: $message, type: $type, statusCode: $statusCode)';
}

/// Hata tipleri
enum ErrorType {
  /// Ağ bağlantısı hatası
  network,

  /// Sunucu hatası (5xx)
  server,

  /// Kimlik doğrulama hatası (401, 403)
  authentication,

  /// Validasyon hatası (400)
  validation,

  /// İstenen kaynak bulunamadı (404)
  notFound,

  /// Zaman aşımı hatası
  timeout,

  /// İzin hatası
  permission,

  /// Bilinmeyen hata
  unknown,
}

/// Result extension metodları
extension ResultX<T> on Result<T> {
  /// Başarılı mı?
  bool get isSuccess => this is Success<T>;

  /// Başarısız mı?
  bool get isFailure => this is Failure<T>;

  /// Data'yı al, yoksa null döndür
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  /// Data'yı al, yoksa default değer döndür
  T getOrElse(T defaultValue) =>
      this is Success<T> ? (this as Success<T>).data : defaultValue;

  /// Data'yı al, yoksa exception fırlat
  T getOrThrow() {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    } else {
      throw Exception((this as Failure<T>).message);
    }
  }

  /// Pattern matching
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure<T> failure) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).data);
    } else {
      return failure(this as Failure<T>);
    }
  }

  /// Pattern matching with default
  R maybeWhen<R>({
    R Function(T data)? success,
    R Function(Failure<T> failure)? failure,
    required R Function() orElse,
  }) {
    if (this is Success<T> && success != null) {
      return success((this as Success<T>).data);
    } else if (this is Failure<T> && failure != null) {
      return failure(this as Failure<T>);
    }
    return orElse();
  }

  /// Map data
  Result<R> map<R>(R Function(T data) transform) {
    if (this is Success<T>) {
      return Success(transform((this as Success<T>).data));
    }
    return Failure(
      message: (this as Failure<T>).message,
      type: (this as Failure<T>).type,
      statusCode: (this as Failure<T>).statusCode,
    );
  }

  /// FlatMap data
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    if (this is Success<T>) {
      return transform((this as Success<T>).data);
    }
    return Failure(
      message: (this as Failure<T>).message,
      type: (this as Failure<T>).type,
      statusCode: (this as Failure<T>).statusCode,
    );
  }

  /// Fold
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure<T> failure) onFailure,
  }) => when(success: onSuccess, failure: onFailure);
}

// ignore: unintended_html_in_doc_comment
/// Future<Result<T>> için extension metodları
extension FutureResultX<T> on Future<Result<T>> {
  /// Async pattern matching
  Future<R> whenAsync<R>({
    required Future<R> Function(T data) success,
    required Future<R> Function(Failure<T> failure) failure,
  }) async {
    final result = await this;
    if (result is Success<T>) {
      return success(result.data);
    } else {
      return failure(result as Failure<T>);
    }
  }

  /// Async map
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    final result = await this;
    if (result is Success<T>) {
      final transformed = await transform(result.data);
      return Success(transformed);
    }
    return Failure(
      message: (result as Failure<T>).message,
      type: result.type,
      statusCode: result.statusCode,
    );
  }
}
