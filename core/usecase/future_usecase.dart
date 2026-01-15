/// An abstract class defining a contract for asynchronous, single-result operations.
///
/// [Type] is the return type of the operation.
/// [Params] is the type of the input parameters.
///
/// Use this class when you need to perform a single async action that returns
/// a single result (e.g., network requests, DB fetches, etc.).
// ignore: avoid_types_as_parameter_names
abstract class FutureUseCase<Type, Params> {
  /// Executes the use case.
  ///
  /// The [params] argument may be null if the operation doesn't require inputs.
  ///
  /// Returns a [Future] of [Type].
  Future<Type> call({Params? params});
}
