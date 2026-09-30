sealed class ApiResponse<T> {}

class Loading<T> extends ApiResponse<T> {}

class Success<T> extends ApiResponse<T> {
  final T data;
  Success(this.data);
}

class Error<T> extends ApiResponse<T> {
  final String message;
  Error(this.message);
}
