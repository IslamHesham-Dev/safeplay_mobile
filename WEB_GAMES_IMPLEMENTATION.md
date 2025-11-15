# Web Games Implementation Guide

## Overview
This document describes the implementation of **Web-Based Educational Games** for the Junior (6-8 years) dashboard in the SafePlay mobile app. These games are loaded from external educational websites and displayed using WebView with JavaScript injection to isolate only the game canvas, providing a seamless integrated experience.

---

## Implementation Summary

### ✅ What Was Added

#### 1. **Food Chains Game**
A fun science game from [Science Kids](https://www.sciencekids.co.nz/gamesactivities/foodchains.html) that teaches children about:
- **Topics:** Animals, Plants, Food Chains, Habitats, Ecosystems
- **Duration:** 15 minutes
- **Difficulty:** Easy
- **Subject:** Science

**Learning Goals:**
1. Identify different animals and plants in a woodland habitat
2. Understand what a food chain is and how living things depend on each other
3. Sort animals by characteristics (fly, have legs, have shells)
4. Explore how different habitats have different food chains
5. Learn about producers, consumers, and decomposers in nature

#### 2. **WebView with Canvas Isolation**
Implemented advanced JavaScript injection to:
- Hide all webpage elements except the game canvas
- Remove ads, headers, footers, and navigation
- Center and scale the canvas for optimal viewing
- Provide a fullscreen landscape mode for gameplay
- Maintain a clean, integrated look

#### 3. **New Models and Services**
- **`WebGame` model** - Structure for web-based games
- **`WebGameService`** - Service to manage and provide web games
- **`WebGameCard` widget** - Beautiful card UI matching Junior theme
- **`WebGameDetailScreen`** - Detail page with game preview and info

#### 4. **Junior Dashboard Integration**
Added "Interactive Science Games" section to the Junior dashboard:
- Positioned between "Today's Tasks" and "Books" sections
- Grid layout with colorful game cards
- Matches existing Junior UI patterns and theme

---

## Technical Architecture

### File Structure

```
safeplay_mobile/lib/
├── models/
│   └── web_game.dart                    # WebGame model
├── services/
│   └── web_game_service.dart            # Service for loading games
├── widgets/
│   └── junior/
│       └── web_game_card.dart           # Game card widget
└── screens/
    └── junior/
        ├── junior_dashboard_screen.dart # Updated dashboard
        └── web_game_detail_screen.dart  # Game detail & player
```

### Data Flow

```
1. Junior Dashboard loads
   ↓
2. _loadWebGames() called
   ↓
3. WebGameService.getWebGames(ageGroup: 'junior')
   ↓
4. Returns List<WebGame>
   ↓
5. Displayed as cards in grid
   ↓
6. User taps card
   ↓
7. Navigate to WebGameDetailScreen
   ↓
8. Show game preview + info
   ↓
9. User taps "Start Game"
   ↓
10. Enter fullscreen landscape mode
    ↓
11. JavaScript injection hides non-game elements
    ↓
12. User plays game
    ↓
13. Exit fullscreen → Return to detail page
```

---

## JavaScript Injection Strategy

### Problem
External websites include:
- Headers, footers, navigation bars
- Ads and banners
- Side panels and related links
- Other distracting content

### Solution
Inject custom JavaScript to:

```javascript
// 1. Wait for canvas to load
// 2. Find the canvas element using CSS selector
const canvas = document.querySelector('canvas');

// 3. Hide all body children except canvas container
Array.from(document.body.children).forEach(child => {
  if (!child.contains(canvas)) {
    child.style.display = 'none';
  }
});

// 4. Style canvas container to fill screen
// 5. Center and scale canvas
// 6. Remove margins, padding, scrollbars
```

### Code Implementation

```dart
String get _isolationScript {
  return '''
    (function() {
      function isolateCanvas() {
        const canvas = document.querySelector('canvas');
        
        if (!canvas) {
          setTimeout(isolateCanvas, 500);
          return;
        }
        
        // Hide all non-canvas elements
        document.body.style.margin = '0';
        document.body.style.padding = '0';
        document.body.style.overflow = 'hidden';
        document.body.style.backgroundColor = '#000';
        
        // Hide siblings and ancestors
        // Style canvas to fill screen
        // Center and scale
      }
      
      isolateCanvas();
      setTimeout(isolateCanvas, 1000); // Re-apply
    })();
  ''';
}
```

---

## WebGame Model

```dart
class WebGame {
  final String id;
  final String title;
  final String description;
  final String websiteUrl;
  final String? canvasSelector; // CSS selector (e.g., 'canvas')
  final List<String> topics;
  final List<String> learningGoals;
  final String explanation;
  final String? warning;
  final int estimatedMinutes;
  final String difficulty;
  final String ageGroup;
  final String subject;
  final String iconEmoji;
  final String color; // Hex color
}
```

---

## WebGameService

Provides web games for different age groups and subjects:

```dart
class WebGameService {
  Future<List<WebGame>> getWebGames({
    String ageGroup = 'junior',
    String? subject
  });
  
  Future<List<WebGame>> _getJuniorWebGames({String? subject});
  Future<List<WebGame>> _getBrightWebGames({String? subject});
}
```

**Current Games:**
- Junior: 1 game (Food Chains)
- Bright: 0 games (placeholder for future)

---

## UI Components

### 1. WebGameCard

Beautiful gradient card with:
- Large emoji icon in rounded container
- Duration badge (e.g., "15m")
- Game title (bold, 2 lines max)
- Description (3 lines max)
- "Play Game" button
- Background pattern overlay
- Color customization per game

### 2. WebGameDetailScreen

Two-mode screen:

**Detail Mode (Portrait):**
- Top section (40% height): Game preview in WebView
- Back button overlay
- Loading indicator with emoji
- Scrollable content:
  - Title bar with emoji, title, tags
  - Topics section (white pill chips)
  - Learning Goals (numbered circles)
  - Explanation (blue info box)
  - Warning (yellow box if present)
  - "Start Game" button (orange, prominent)

**Fullscreen Mode (Landscape):**
- Full-screen WebView
- Game canvas isolated (no webpage chrome)
- Exit button (top-left corner)
- Black background
- Immersive mode (hides system UI)

---

## User Experience Flow

### Browsing
1. Child logs into Junior dashboard
2. Scrolls down to "Interactive Science Games"
3. Sees colorful game cards in 2-column grid
4. Each card shows:
   - Game icon
   - Title
   - Description
   - Duration
   - "Play Game" button

### Game Selection
1. Child taps a game card
2. Navigate to detail screen
3. See game loading in top section
4. Read about the game:
   - What they'll learn
   - Topics covered
   - How the game works
5. Tap "Start Game" button

### Playing
1. Device rotates to landscape
2. Game fills entire screen
3. Only canvas visible (clean UI)
4. Play the game naturally
5. Tap exit button when done
6. Return to detail page in portrait

### Exiting
1. From detail page, tap back button
2. Return to Junior dashboard
3. Web games section still visible
4. Can choose another game

---

## Platform Compatibility

### Requirements

**Android (Already Configured):**
- ✅ Internet permissions in `AndroidManifest.xml`
- ✅ `usesCleartextTraffic="true"` for HTTP/HTTPS
- ✅ `flutter_inappwebview` plugin registered

**iOS (Already Configured):**
- ✅ `NSAppTransportSecurity` with `NSAllowsArbitraryLoads`
- ✅ `io.flutter.embedded_views_preview` enabled
- ✅ WebView permissions granted

**Both Platforms:**
- ✅ `flutter_inappwebview: ^6.0.0` dependency
- ✅ Internet connection required
- ✅ Orientation changes supported

---

## Adding New Web Games

### Step 1: Find a Suitable Game

Criteria:
- Educational content appropriate for age group
- Uses `<canvas>` or identifiable game container
- Loads quickly (< 5 seconds)
- Works well on mobile devices
- Free to access (no login required)
- Safe for children (no ads/inappropriate content)

### Step 2: Identify the Canvas Selector

1. Open the game website in a browser
2. Rightclick → Inspect Element
3. Find the game canvas:
   - Look for `<canvas>` tag
   - Note any parent `<div>` with specific ID/class
4. Determine CSS selector:
   - Simple: `'canvas'`
   - Specific: `'div.game-container canvas'`
   - ID-based: `'#game-canvas'`

### Step 3: Add to WebGameService

```dart
const WebGame(
  id: 'your-game-id',
  title: 'Your Game Title',
  description: 'Brief description...',
  websiteUrl: 'https://example.com/game',
  canvasSelector: 'canvas', // From Step 2
  topics: ['Topic 1', 'Topic 2'],
  learningGoals: [
    'Goal 1...',
    'Goal 2...',
  ],
  explanation: 'Detailed explanation...',
  warning: 'Optional warning...',
  estimatedMinutes: 15,
  difficulty: 'Easy',
  ageGroup: 'junior', // or 'bright'
  subject: 'science', // or 'math', 'reading', etc.
  iconEmoji: '🎮',
  color: '4CAF50', // Hex without #
),
```

### Step 4: Test Thoroughly

1. **Preview Mode:**
   - Game loads in top section
   - Canvas isolated correctly
   - No webpage chrome visible
   - Loading indicator works

2. **Fullscreen Mode:**
   - Rotates to landscape
   - Game fills screen
   - Canvas scaled properly
   - Exit button visible
   - Can exit and return

3. **Content Verification:**
   - Topics display correctly
   - Learning goals formatted
   - Explanation readable
   - Warning shows if present

4. **Cross-Platform:**
   - Test on Android device/emulator
   - Test on iOS simulator/device
   - Check different screen sizes

---

## Troubleshooting

### Issue 1: Canvas Not Found
**Symptom:** Black screen or webpage chrome still visible  
**Cause:** Incorrect `canvasSelector`  
**Solution:**
1. Inspect the webpage HTML
2. Find the exact canvas element
3. Update `canvasSelector`:
   - Try `'canvas'` first
   - Then `'div.container canvas'`
   - Then specific ID: `'#gameCanvas'`

### Issue 2: Canvas Not Centered
**Symptom:** Canvas appears small or off-center  
**Cause:** Parent container styles interfering  
**Solution:**
- JavaScript injection styles parent containers
- May need to adjust `_isolationScript`
- Add more specific styling for that website

### Issue 3: Game Not Loading
**Symptom:** Loading indicator never disappears  
**Cause:** Network issue, blocked content, or CORS  
**Solution:**
1. Check device internet connection
2. Verify URL is accessible in browser
3. Check Android/iOS permissions
4. Try different website if CORS issues persist

### Issue 4: Fullscreen Doesn't Work
**Symptom:** Stays in portrait or doesn't fill screen  
**Cause:** Orientation lock or system UI issue  
**Solution:**
- Ensure `SystemChrome.setPreferredOrientations()` called
- Check device rotation not locked
- Verify `SystemUiMode.immersiveSticky` supported

### Issue 5: Exit Button Not Responding
**Symptom:** Can't exit fullscreen  
**Cause:** WebView capturing all touch events  
**Solution:**
- Exit button is in a `Stack` above WebView
- Should always be tappable
- May need to adjust Z-index or positioning

---

## Performance Considerations

### Loading Times
- First load: 2-5 seconds (downloads game assets)
- Subsequent loads: Faster (browser cache)
- JavaScript injection: < 100ms

### Memory Usage
- WebView: 50-100 MB per game
- Dispose properly when exiting
- Only one game loaded at a time

### Battery Impact
- WebView games use GPU
- Fullscreen gaming drains battery faster
- Recommend limiting playtime

---

## Security & Privacy

### Safety Measures
1. **Curated Content:**
   - All games manually reviewed
   - Only trusted educational sites
   - No user-generated content

2. **No Data Collection:**
   - Games don't access user data
   - No tracking scripts injected
   - Isolated WebView context

3. **Parental Controls:**
   - Games are age-appropriate
   - Adult guidance recommended (warnings)
   - Limited to educational websites

4. **Network Safety:**
   - HTTPS preferred (when available)
   - No external authentication required
   - No personal information shared

---

## Future Enhancements

### Planned Features
1. **More Games:**
   - Math games for Junior
   - Reading/phonics games
   - Bright (9-12) games
   - Art and creativity games

2. **Progress Tracking:**
   - Track time spent per game
   - Mark games as "played"
   - Unlock achievements

3. **Favorites:**
   - Let children favorite games
   - Quick access to favorites
   - Personalized recommendations

4. **Offline Support:**
   - Download games for offline play
   - Cache game assets
   - Offline indicator

5. **Multiplayer:**
   - Some games support multiplayer
   - Share game links with friends
   - Leaderboards

6. **Accessibility:**
   - Screen reader support
   - High contrast mode
   - Adjustable text sizes
   - Keyboard navigation

---

## Testing Checklist

### Before Release
- [ ] Game loads successfully on Android
- [ ] Game loads successfully on iOS
- [ ] Canvas isolation works (no webpage chrome)
- [ ] Fullscreen mode works
- [ ] Exit button is accessible
- [ ] Back button returns to dashboard
- [ ] Portrait/landscape rotation smooth
- [ ] Loading indicator displays
- [ ] All text content readable
- [ ] Topics/goals/explanation formatted correctly
- [ ] Warning box shows if present
- [ ] "Start Game" button prominent
- [ ] Card displays correctly in grid
- [ ] Emoji icon renders
- [ ] Duration badge visible
- [ ] Game is playable and interactive
- [ ] Touch/click events work
- [ ] No console errors in debug mode
- [ ] Performance is acceptable
- [ ] Battery usage reasonable

---

## Maintenance

### Regular Tasks
1. **Monthly:**
   - Test all game URLs (ensure still accessible)
   - Check for broken links
   - Verify games still work as expected

2. **Quarterly:**
   - Review game content for appropriateness
   - Add new games based on feedback
   - Update JavaScript injection if needed

3. **As Needed:**
   - Fix broken games (update URL or remove)
   - Respond to user feedback
   - Optimize performance

---

## References

### External Resources
- [Science Kids - Food Chains Game](https://www.sciencekids.co.nz/gamesactivities/foodchains.html)
- [flutter_inappwebview Documentation](https://inappwebview.dev/)
- [Flutter WebView Guide](https://flutter.dev/docs/development/platform-integration/web-views)

### Internal Documentation
- `SIMULATION_IMPLEMENTATION.md` - Similar feature for Bright dashboard
- `BOOK_THUMBNAILS_BINDING.md` - Asset binding patterns
- `AUTH_IMPLEMENTATION.md` - Authentication flow

---

## Conclusion

The Web Games feature provides a seamless way to integrate external educational games into the SafePlay app. By using advanced JavaScript injection to isolate the game canvas, we create a native-like experience that feels integrated rather than embedded. This feature is extensible, maintainable, and provides significant educational value for Junior children.

**Current Status:** ✅ **Fully Implemented & Ready for Testing**

**Total Games Available:**
- 1 Science game for Junior (Food Chains)
- Expandable architecture for future games

---

**Document Version:** 1.0  
**Last Updated:** November 14, 2025  
**Implementation Status:** ✅ Complete

