/// Uygulama genelinde state yönetimi için kullanılan gelişmiş handler sınıfı.
///
/// Generic tip desteği ile herhangi bir veri tipini taşıyabilir.
/// Immutable yapıda olup, state değişiklikleri için copyWith metodunu kullanır.
///
/// ## Özellikler:
/// - ✅ Generic tip desteği (`<T>`)
/// - ✅ Loading, Success, Error durumları
/// - ✅ Pagination desteği (loadingMore)
/// - ✅ Pull-to-refresh desteği
/// - ✅ **Filtreleme desteği** (filtering, filtered)
/// - ✅ **Arama desteği** (searching, searched)
/// - ✅ Pattern matching (when, maybeWhen)
/// - ✅ Orijinal veri saklama
///
/// ## Kullanım örnekleri:
///
/// ### Basit kullanım:
/// ```dart
/// StateHandlerV2<List<User>> state = StateHandlerV2.loading();
/// state = StateHandlerV2.success(data: users);
/// state = StateHandlerV2.error(message: 'Bir hata oluştu');
/// ```
///
/// ### Filtreleme:
/// ```dart
/// // Filtreleme başlat
/// state = StateHandlerV2.filtering(
///   originalData: allUsers,
///   filters: {'role': 'admin', 'isActive': true},
/// );
///
/// // Filtrelenmiş sonuç
/// state = StateHandlerV2.filtered(
///   data: filteredUsers,
///   originalData: allUsers,
///   filters: {'role': 'admin'},
/// );
///
/// // Filtreleri temizle
/// state = state.clearFilters();
/// ```
///
/// ### Arama:
/// ```dart
/// // Arama başlat
/// state = StateHandlerV2.searching(
///   originalData: allProducts,
///   searchQuery: 'laptop',
/// );
///
/// // Arama sonucu
/// state = StateHandlerV2.searched(
///   data: searchResults,
///   originalData: allProducts,
///   searchQuery: 'laptop',
/// );
///
/// // Aramayı temizle
/// state = state.clearSearch();
/// ```
///
/// ### Pattern Matching:
/// ```dart
/// state.when(
///   initial: () => SizedBox(),
///   loading: () => CircularProgressIndicator(),
///   success: (data) => ListView(children: data),
///   error: (msg, err) => ErrorWidget(msg),
///   empty: () => EmptyWidget(),
///   filtering: (data, filters) => FilteringIndicator(filters),
///   searching: (data, query) => SearchingIndicator(query),
/// );
/// ```
class StateHandler<T> {
  final bool isLoading;
  final bool isError;
  final bool isSuccess;
  final bool isEmpty;
  final bool isNotEmpty;
  final bool isInitial;
  final bool isLoadingMore;
  final bool isLoadingMoreError;
  final bool isLoadingMoreSuccess;
  final bool isRefreshing;
  final bool isFiltering;
  final bool isSearching;
  final String? message;
  final T? data;
  final T? originalData; // Filtrelenmemiş orijinal veri
  final Map<String, dynamic>? filters; // Aktif filtreler
  final String? searchQuery; // Arama sorgusu
  final dynamic error;
  final StackTrace? stackTrace;

  const StateHandler({
    this.isLoading = false,
    this.isError = false,
    this.isSuccess = false,
    this.isEmpty = false,
    this.isNotEmpty = false,
    this.isInitial = false,
    this.isLoadingMore = false,
    this.isLoadingMoreError = false,
    this.isLoadingMoreSuccess = false,
    this.isRefreshing = false,
    this.isFiltering = false,
    this.isSearching = false,
    this.message,
    this.data,
    this.originalData,
    this.filters,
    this.searchQuery,
    this.error,
    this.stackTrace,
  });

  /// İlk durum - Hiçbir işlem yapılmamış
  factory StateHandler.initial() {
    return const StateHandler(isInitial: true);
  }

  /// Yükleme durumu
  factory StateHandler.loading({T? data}) {
    return StateHandler(isLoading: true, data: data);
  }

  /// Hata durumu
  factory StateHandler.error({
    required String message,
    dynamic error,
    StackTrace? stackTrace,
    T? data,
  }) {
    return StateHandler(
      isError: true,
      message: message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Başarılı durum
  factory StateHandler.success({String? message, required T data}) {
    return StateHandler(
      isSuccess: true,
      message: message,
      data: data,
      isNotEmpty: true,
    );
  }

  /// Boş veri durumu
  factory StateHandler.empty({String? message}) {
    return StateHandler(isEmpty: true, message: message);
  }

  /// Boş olmayan veri durumu
  factory StateHandler.notEmpty({required T data}) {
    return StateHandler(isNotEmpty: true, data: data);
  }

  /// Daha fazla yükleme durumu (pagination)
  factory StateHandler.loadingMore({required T data}) {
    return StateHandler(isLoadingMore: true, data: data, isNotEmpty: true);
  }

  /// Daha fazla yükleme başarılı durumu
  factory StateHandler.loadingMoreSuccess({required T data, String? message}) {
    return StateHandler(
      isLoadingMoreSuccess: true,
      data: data,
      message: message,
      isNotEmpty: true,
    );
  }

  /// Daha fazla yükleme hata durumu
  factory StateHandler.loadingMoreError({
    required String message,
    required T data,
    dynamic error,
  }) {
    return StateHandler(
      isLoadingMoreError: true,
      data: data,
      message: message,
      error: error,
      isNotEmpty: true,
    );
  }

  /// Yenileme durumu (pull-to-refresh)
  factory StateHandler.refreshing({T? data}) {
    return StateHandler(isRefreshing: true, data: data);
  }

  /// Filtreleme durumu
  factory StateHandler.filtering({
    required T originalData,
    Map<String, dynamic>? filters,
  }) {
    return StateHandler(
      isFiltering: true,
      originalData: originalData,
      filters: filters,
      data: originalData,
    );
  }

  /// Filtrelenmiş veri ile başarılı durum
  factory StateHandler.filtered({
    required T data,
    required T originalData,
    required Map<String, dynamic> filters,
    String? message,
  }) {
    return StateHandler(
      isSuccess: true,
      data: data,
      originalData: originalData,
      filters: filters,
      message: message,
      isNotEmpty: true,
    );
  }

  /// Arama durumu
  factory StateHandler.searching({
    required T originalData,
    required String searchQuery,
  }) {
    return StateHandler(
      isSearching: true,
      originalData: originalData,
      searchQuery: searchQuery,
      data: originalData,
    );
  }

  /// Arama sonucu ile başarılı durum
  factory StateHandler.searched({
    required T data,
    required T originalData,
    required String searchQuery,
    String? message,
  }) {
    return StateHandler(
      isSuccess: true,
      data: data,
      originalData: originalData,
      searchQuery: searchQuery,
      message: message,
      isNotEmpty: true,
    );
  }

  /// Filtreleri temizle
  StateHandler<T> clearFilters() {
    return StateHandler(
      isSuccess: true,
      data: originalData ?? data,
      originalData: null,
      filters: null,
      searchQuery: null,
      isNotEmpty: true,
    );
  }

  /// Aramayı temizle
  StateHandler<T> clearSearch() {
    return StateHandler(
      isSuccess: true,
      data: originalData ?? data,
      originalData: null,
      searchQuery: null,
      filters: filters,
      isNotEmpty: true,
    );
  }

  /// Immutable state güncellemesi için copyWith metodu
  StateHandler<T> copyWith({
    bool? isLoading,
    bool? isError,
    bool? isSuccess,
    bool? isEmpty,
    bool? isNotEmpty,
    bool? isInitial,
    bool? isLoadingMore,
    bool? isLoadingMoreError,
    bool? isLoadingMoreSuccess,
    bool? isRefreshing,
    bool? isFiltering,
    bool? isSearching,
    String? message,
    T? data,
    T? originalData,
    Map<String, dynamic>? filters,
    String? searchQuery,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    return StateHandler<T>(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isSuccess: isSuccess ?? this.isSuccess,
      isEmpty: isEmpty ?? this.isEmpty,
      isNotEmpty: isNotEmpty ?? this.isNotEmpty,
      isInitial: isInitial ?? this.isInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoadingMoreError: isLoadingMoreError ?? this.isLoadingMoreError,
      isLoadingMoreSuccess: isLoadingMoreSuccess ?? this.isLoadingMoreSuccess,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFiltering: isFiltering ?? this.isFiltering,
      isSearching: isSearching ?? this.isSearching,
      message: message ?? this.message,
      data: data ?? this.data,
      originalData: originalData ?? this.originalData,
      filters: filters ?? this.filters,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  /// Herhangi bir loading durumu var mı?
  bool get hasAnyLoading =>
      isLoading || isLoadingMore || isRefreshing || isFiltering || isSearching;

  /// Aktif filtre var mı?
  bool get hasActiveFilters => filters != null && filters!.isNotEmpty;

  /// Aktif arama var mı?
  bool get hasActiveSearch => searchQuery != null && searchQuery!.isNotEmpty;

  /// Herhangi bir filtre veya arama aktif mi?
  bool get isFiltered => hasActiveFilters || hasActiveSearch;

  /// State pattern matching için when metodu
  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message, dynamic error) error,
    required R Function() empty,
    R Function(T data)? loadingMore,
    R Function(T data)? refreshing,
    R Function(T data, Map<String, dynamic> filters)? filtering,
    R Function(T data, String query)? searching,
  }) {
    if (isInitial) return initial();
    if (isLoading &&
        !isLoadingMore &&
        !isRefreshing &&
        !isFiltering &&
        !isSearching) {
      return loading();
    }
    if (isFiltering && data != null && filters != null) {
      return filtering?.call(data as T, filters!) ?? success(data as T);
    }
    if (isSearching && data != null && searchQuery != null) {
      return searching?.call(data as T, searchQuery!) ?? success(data as T);
    }
    if (isLoadingMore && data != null) {
      return loadingMore?.call(data as T) ?? success(data as T);
    }
    if (isRefreshing) {
      return refreshing?.call(data as T) ?? loading();
    }
    if (isError) return error(message ?? 'Bir hata oluştu', this.error);
    if (isEmpty) return empty();
    if (isSuccess && data != null) return success(data as T);
    if (isNotEmpty && data != null) return success(data as T);

    return initial();
  }

  /// Opsiyonel state pattern matching
  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? success,
    R Function(String message, dynamic error)? error,
    R Function()? empty,
    R Function(T data)? loadingMore,
    R Function(T data)? refreshing,
    R Function(T data, Map<String, dynamic> filters)? filtering,
    R Function(T data, String query)? searching,
    required R Function() orElse,
  }) {
    if (isInitial && initial != null) return initial();
    if (isLoading &&
        !isLoadingMore &&
        !isRefreshing &&
        !isFiltering &&
        !isSearching &&
        loading != null) {
      return loading();
    }
    if (isFiltering && data != null && filters != null && filtering != null) {
      return filtering(data as T, filters!);
    }
    if (isSearching &&
        data != null &&
        searchQuery != null &&
        searching != null) {
      return searching(data as T, searchQuery!);
    }
    if (isLoadingMore && data != null && loadingMore != null) {
      return loadingMore(data as T);
    }
    if (isRefreshing && data != null && refreshing != null) {
      return refreshing(data as T);
    }
    if (isError && error != null) {
      return error(message ?? 'Bir hata oluştu', this.error);
    }
    if (isEmpty && empty != null) return empty();
    if ((isSuccess || isNotEmpty) && data != null && success != null) {
      return success(data as T);
    }

    return orElse();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StateHandler<T> &&
        other.isLoading == isLoading &&
        other.isError == isError &&
        other.isSuccess == isSuccess &&
        other.isEmpty == isEmpty &&
        other.isNotEmpty == isNotEmpty &&
        other.isInitial == isInitial &&
        other.isLoadingMore == isLoadingMore &&
        other.isLoadingMoreError == isLoadingMoreError &&
        other.isLoadingMoreSuccess == isLoadingMoreSuccess &&
        other.isRefreshing == isRefreshing &&
        other.isFiltering == isFiltering &&
        other.isSearching == isSearching &&
        other.message == message &&
        other.data == data &&
        other.originalData == originalData &&
        other.filters == filters &&
        other.searchQuery == searchQuery &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      isError,
      isSuccess,
      isEmpty,
      isNotEmpty,
      isInitial,
      isLoadingMore,
      isLoadingMoreError,
      isLoadingMoreSuccess,
      isRefreshing,
      Object.hash(
        isFiltering,
        isSearching,
        message,
        data,
        originalData,
        filters,
        searchQuery,
        error,
      ),
    );
  }

  @override
  String toString() {
    final state = isInitial
        ? 'initial'
        : isLoading
        ? 'loading'
        : isFiltering
        ? 'filtering'
        : isSearching
        ? 'searching'
        : isLoadingMore
        ? 'loadingMore'
        : isRefreshing
        ? 'refreshing'
        : isError
        ? 'error'
        : isEmpty
        ? 'empty'
        : isSuccess
        ? 'success'
        : isNotEmpty
        ? 'notEmpty'
        : 'unknown';

    final extras = <String>[];
    if (message != null) extras.add('message: $message');
    if (data != null) extras.add('hasData: true');
    if (hasActiveFilters) extras.add('filters: ${filters!.keys.join(", ")}');
    if (hasActiveSearch) extras.add('search: "$searchQuery"');

    return 'StateHandlerV2<$T>($state${extras.isNotEmpty ? ', ${extras.join(", ")}' : ''})';
  }
}
