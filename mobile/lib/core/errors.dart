/// Same exception for "does not exist" and "not yours" (mirrors the API 404).
class NotFoundException implements Exception {
  const NotFoundException();
}