---
name: Flutter Best Practices
inclusion: fileMatch
fileMatchPattern: "lib/**/*.dart"
description: Flutter-specific UI and widget best practices
---

# Flutter Best Practices

## Widget Decomposition

- No single widget with a `build()` method exceeding ~80-100 lines
- Widgets split by encapsulation AND by how they change (rebuild boundaries)
- Private `_build*()` helper methods that return widgets are extracted to separate widget classes
- Stateless widgets preferred over Stateful where no mutable local state is needed
- Extracted widgets are in separate files when reusable

## Const Usage

- `const` constructors used wherever possible — prevents unnecessary rebuilds
- `const` literals for collections that don't change (`const []`, `const {}`)
- Constructor is declared `const` when all fields are final

## Key Usage

- `ValueKey` used in lists/grids to preserve state across reorders
- `GlobalKey` used sparingly — only when accessing state across the tree is truly needed
- `UniqueKey` avoided in `build()` — it forces rebuild every frame
- `ObjectKey` used when identity is based on a data object rather than a single value

## Theming & Design System

- Colors come from `Theme.of(context).colorScheme` — no hardcoded `Colors.red` or hex values
- Text styles come from `Theme.of(context).textTheme` — no inline `TextStyle` with raw font sizes
- Dark mode compatibility verified — no assumptions about light background
- Spacing and sizing use consistent design tokens or constants, not magic numbers

## Build Method Complexity

- No network calls, file I/O, or heavy computation in `build()`
- No `Future.then()` or `async` work in `build()`
- No subscription creation (`.listen()`) in `build()`
- `setState()` localized to smallest possible subtree

## State Management

- Business logic lives outside the widget layer — in a state management component
- State managers receive dependencies via injection, not by constructing them internally
- A service or repository layer abstracts data sources
- State managers have a single responsibility
- Immutable state objects with `copyWith()` for mutations
- Sealed types for mutually exclusive states (not boolean flags)

## Performance

### Unnecessary Rebuilds
- `setState()` not called at root widget level — localize state changes
- `const` widgets used to stop rebuild propagation
- `RepaintBoundary` used around complex subtrees that repaint independently
- `AnimatedBuilder` child parameter used for subtrees independent of animation

### Expensive Operations
- No sorting, filtering, or mapping large collections in `build()`
- No regex compilation in `build()`
- `MediaQuery.of(context)` usage is specific (e.g., `MediaQuery.sizeOf(context)`)

### Image Optimization
- Network images use caching
- Appropriate image resolution for target device
- `Image.asset` with `cacheWidth`/`cacheHeight` to decode at display size
- Placeholder and error widgets provided for network images

### Lazy Loading
- `ListView.builder` / `GridView.builder` used instead of `ListView(children: [...])`
- Pagination implemented for large data sets
- Deferred loading (`deferred as`) used for heavy libraries in web builds

## Accessibility

### Semantic Widgets
- `Semantics` widget used to provide screen reader labels
- `ExcludeSemantics` used for purely decorative elements
- `MergeSemantics` used to combine related widgets
- Images have `semanticLabel` property set

### Screen Reader Support
- All interactive elements are focusable and have meaningful descriptions
- Focus order is logical (follows visual reading order)

### Visual Accessibility
- Contrast ratio >= 4.5:1 for text against background
- Tappable targets are at least 48x48 pixels
- Color is not the sole indicator of state (use icons/text alongside)
- Text scales with system font size settings

## Platform-Specific Concerns

### iOS/Android Differences
- Platform-adaptive widgets used where appropriate
- Back navigation handled correctly
- Status bar and safe area handled via `SafeArea` widget
- Platform-specific permissions declared in `AndroidManifest.xml` and `Info.plist`

### Responsive Design
- `LayoutBuilder` or `MediaQuery` used for responsive layouts
- Breakpoints defined consistently (phone, tablet, desktop)
- Text doesn't overflow on small screens — use `Flexible`, `Expanded`, `FittedBox`
- Landscape orientation tested or explicitly locked
- Web-specific: mouse/keyboard interactions supported, hover states present

## Error Handling

### Framework Error Handling
- `FlutterError.onError` overridden to capture framework errors
- `PlatformDispatcher.instance.onError` set for async errors
- `ErrorWidget.builder` customized for release mode
- Global error capture wrapper around `runApp`

### Error Reporting
- Error reporting service integrated (Firebase Crashlytics, Sentry, etc.)
- Non-fatal errors reported with stack traces
- State management error observer wired to error reporting
- User-identifiable info (user ID) attached to error reports

### Graceful Degradation
- API errors result in user-friendly error UI, not crashes
- Retry mechanisms for transient network failures
- Offline state handled gracefully
- Error states in state management carry error info for display

---

**Reference:** `.kiro/skills/flutter-dart-code-review/SKILL.md`
