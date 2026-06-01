/// DTO for the response from the login API.
class LoginResponseDto {
  final String accessToken;
  final String tokenType;

  const LoginResponseDto({
    required this.accessToken,
    required this.tokenType,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
    );
  }
}
