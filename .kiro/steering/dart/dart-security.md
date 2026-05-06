---
name: Dart/Flutter Security
inclusion: fileMatch
fileMatchPattern: "**/*.dart"
description: Dart and Flutter security guidelines
---

# Dart/Flutter Security

## Secrets Management

- Never hardcode API keys, tokens, or credentials in Dart source
- Use `--dart-define` or `--dart-define-from-file` for compile-time config
- Use `flutter_dotenv` or equivalent, with `.env` files listed in `.gitignore`
- Store runtime secrets in platform-secure storage: `flutter_secure_storage`

```dart
// BAD
const apiKey = 'sk-abc123...';

// GOOD — compile-time config (not secret, just configurable)
const apiKey = String.fromEnvironment('API_KEY');

// GOOD — runtime secret from secure storage
final token = await secureStorage.read(key: 'auth_token');
```

## Network Security

- Enforce HTTPS — no `http://` calls in production
- Configure Android `network_security_config.xml` to block cleartext traffic
- Set `NSAppTransportSecurity` in `Info.plist` to disallow arbitrary loads
- Set request timeouts on all HTTP clients — never leave defaults
- Consider certificate pinning for high-security endpoints

```dart
// Dio with timeout and HTTPS enforcement
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 30),
));
```

## Input Validation

- Validate and sanitize all user input before sending to API or storage
- Never pass unsanitized input to SQL queries — use parameterized queries
- Sanitize deep link URLs before navigation — validate scheme, host, and path parameters
- Use `Uri.tryParse` and validate before navigating

```dart
// BAD — SQL injection
await db.rawQuery("SELECT * FROM users WHERE email = '$userInput'");

// GOOD — parameterized
await db.query('users', where: 'email = ?', whereArgs: [userInput]);

// BAD — unvalidated deep link
final uri = Uri.parse(incomingLink);
context.go(uri.path); // could navigate to any route

// GOOD — validated deep link
final uri = Uri.tryParse(incomingLink);
if (uri != null && uri.host == 'myapp.com' && _allowedPaths.contains(uri.path)) {
  context.go(uri.path);
}
```

## Data Protection

- Store tokens, PII, and credentials only in `flutter_secure_storage`
- Never write sensitive data to `SharedPreferences` or local files in plaintext
- Clear auth state on logout: tokens, cached user data, cookies
- Use biometric authentication (`local_auth`) for sensitive operations
- Avoid logging sensitive data — no `print(token)` or `debugPrint(password)`

## Android-Specific

- Declare only required permissions in `AndroidManifest.xml`
- Export Android components only when necessary; add `android:exported="false"` where not needed
- Review intent filters — exported components with implicit intent filters are accessible by any app
- Use `FLAG_SECURE` for screens displaying sensitive data (prevents screenshots)

## iOS-Specific

- Declare only required usage descriptions in `Info.plist`
- Store secrets in Keychain — `flutter_secure_storage` uses Keychain on iOS
- Use App Transport Security (ATS) — disallow arbitrary loads
- Enable data protection entitlement for sensitive files

## WebView Security

- Use `webview_flutter` v4+ with `WebViewController`
- Disable JavaScript unless explicitly required (`JavaScriptMode.disabled`)
- Validate URLs before loading — never load arbitrary URLs from deep links
- Use `NavigationDelegate.onNavigationRequest` to intercept and validate navigation requests

```dart
final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.disabled)
  ..setNavigationDelegate(
    NavigationDelegate(
      onNavigationRequest: (request) {
        final uri = Uri.tryParse(request.url);
        if (uri == null || uri.host != 'trusted.example.com') {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    ),
  );
```

## Obfuscation and Build Security

- Enable obfuscation in release builds: `flutter build apk --obfuscate --split-debug-info=./debug-info/`
- Keep `--split-debug-info` output out of version control
- Ensure ProGuard/R8 rules don't inadvertently expose serialized classes
- Run `flutter analyze` and address all warnings before release

---

**Reference:** `.claude/rules/dart/security.md`
