/// What the phone last saw, and when it got it from the server.
class CachedValue<T> {
  const new(this.data, this.fetchedAt);

  final T data;
  final DateTime fetchedAt;
}
