/// A contract for a use case that provides a [Stream] of data.
///
/// This abstract class follows a pattern similar to `UseCase`,
/// but instead of returning a `Future<Type>`, it returns a `Stream<Type>`.
// ignore: avoid_types_as_parameter_names
abstract class StreamUseCase<Type, Params> {
  /// Executes the use case with the given [Params] (if any), and returns a [Stream] of [Type].
  ///
  /// Typically used for scenarios where continuous data updates or real-time
  /// streams are needed (database updates, websockets, etc.).
  Stream<Type> call({Params? params});
}
