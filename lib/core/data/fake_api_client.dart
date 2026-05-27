class FakeApiClient {
  const FakeApiClient();

  Future<T> request<T>(T Function() resolver, {Duration delay = const Duration(milliseconds: 250)}) async {
    await Future<void>.delayed(delay);
    return resolver();
  }
}
