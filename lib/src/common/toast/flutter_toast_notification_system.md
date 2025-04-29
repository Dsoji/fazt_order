# Flutter Toast Notification System

A modern, interactive toast notification system for Flutter applications with stacking, animations, and rich user interactions.

## Features

- 🎨 Multiple toast styles (3 preset styles)
- 🔄 Interactive animations
- 👆 Gesture support (tap, double tap, swipe)
- 📚 Stackable notifications
- ⏱️ Auto-dismissal
- 🎯 Four notification types (Success, Error, Warning, Info)

## Usage

### 1. Wrap Your App

First, wrap your MaterialApp with the ToastWrapper:

```dart
void main() {
  runApp(
    ToastWrapper(
      style: ToastStyle.style1, // Optional: Choose a preset style
      child: MaterialApp(
        home: MyHomePage(),
      ),
    ),
  );
}
```

### 2. Show Toasts

Use the ToastProvider to show notifications anywhere in your app:

```dart
// Show a success toast
ToastProvider.of(context)?.showToast(NotificationType.success);

// Show an error toast
ToastProvider.of(context)?.showToast(NotificationType.error);

// Show an info toast
ToastProvider.of(context)?.showToast(NotificationType.info);

// Show a warning toast
ToastProvider.of(context)?.showToast(NotificationType.warning);
```

### 3. Customize Toast Style

Change the toast style dynamically:

```dart
ToastProvider.of(context)?.setStyle(ToastStyle.style2);
```

## Toast Styles

1. **Style1**: White background with colored icons
2. **Style2**: Colored background with white text and icons
3. **Style3**: Light colored background with border and colored icons

## Interactions

- **Single Tap**: Expands/Collapses the toast stack
- **Double Tap**: Moves toast to top and resets its timer
- **Swipe**: Dismisses the toast
- **Close Button**: Manually removes the toast

## Auto-Dismissal

Toasts automatically dismiss after 5 seconds, unless:
- User double-taps (resets timer)
- Toast is manually closed
- Toast is swiped away

## Animation Details

- Smooth entry/exit animations
- Scale transitions for stacked toasts
- Position animations for expand/collapse
- Swipe-to-dismiss with physics

## Toast Types and Colors

```dart
enum NotificationType {
  info,    // Blue
  error,   // Red
  warning, // Yellow
  success  // Green
}
```

## Notes

- Maximum visible toasts: No limit (scrollable in expanded mode)
- Toast stack appears at the top of the screen
- All toasts are responsive and adapt to screen width
- Supports both light and dark mode

## Implementation Example

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => ToastProvider.of(context)?.showToast(
                NotificationType.success
              ),
              child: Text('Show Success Toast'),
            ),
            // Add more buttons for other toast types...
          ],
        ),
      ),
    );
  }
}
```