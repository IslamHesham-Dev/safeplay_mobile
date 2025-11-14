# Math Simulations - Quick Start Guide

## 🚀 How to Test the New Math Simulations

### Step 1: Run the App
```bash
cd safeplay_mobile
flutter run
```

### Step 2: Navigate to Bright Dashboard
1. Open the app
2. Log in as a child (age 9-12) or create a new Bright child profile
3. You'll land on the Bright dashboard

### Step 3: Scroll to Math Section
- Scroll down past the "Science Simulations" section
- Look for the **"Math Simulations 🔢 PhET"** header with an orange badge
- You should see 4 simulation cards in a 2x2 grid:

```
┌────────────────┬────────────────┐
│   Equality     │   Area Model   │
│   Explorer:    │  Introduction  │
│    Basics      │                │
│   (Orange)     │   (Purple)     │
└────────────────┴────────────────┘
┌────────────────┬────────────────┐
│     Mean:      │   Balancing    │
│  Share and     │      Act       │
│    Balance     │                │
│     (Blue)     │    (Green)     │
└────────────────┴────────────────┘
```

### Step 4: Test Each Simulation

#### Test 1: Equality Explorer: Basics
1. Tap the orange "Equality Explorer: Basics" card
2. **Verify Detail Screen:**
   - ✅ Title: "Equality Explorer: Basics"
   - ✅ Tags: "20 mins" + "Easy Peasy" + ❤️
   - ✅ Topics: Equations, Inequalities, Proportional Reasoning
   - ✅ 4 Learning Goals (numbered 1-4)
   - ✅ Scientific Explanation about balance scales
   - ✅ Warning box
   - ✅ "Start Simulation" button
3. Tap "Start Simulation" or Play in iframe
4. **Verify Fullscreen:**
   - ✅ Device rotates to landscape
   - ✅ Simulation fills entire screen
   - ✅ Can interact with balance scale
5. Exit fullscreen (back button or device back)
6. **Verify Return:**
   - ✅ Returns to portrait
   - ✅ Detail page still visible

#### Test 2: Area Model Introduction
1. Tap the purple "Area Model Introduction" card
2. **Verify Detail Screen:**
   - ✅ Title: "Area Model Introduction"
   - ✅ Tags: "20 mins" + "Easy Peasy" + ❤️
   - ✅ Topics: Factors, Products, Area Model, Multiplication, Partial Products (5 tags)
   - ✅ 4 Learning Goals about rectangles and multiplication
3. Test fullscreen functionality
4. Verify you can interact with rectangles and see area calculations

#### Test 3: Mean: Share and Balance
1. Tap the blue "Mean: Share and Balance" card
2. **Verify Detail Screen:**
   - ✅ Title: "Mean: Share and Balance"
   - ✅ Tags: "15 mins" + "Easy Peasy" + ❤️
   - ✅ Topics: Central Tendency, Mean (2 tags)
   - ✅ 5 Learning Goals (numbered 1-5)
   - ✅ Explanation about averages and leveling
3. Test fullscreen functionality
4. Verify you can interact with data points and see mean calculations

#### Test 4: Balancing Act
1. Tap the green "Balancing Act" card
2. **Verify Detail Screen:**
   - ✅ Title: "Balancing Act"
   - ✅ Tags: "20 mins" + "Medium" + ❤️ (Note: Medium difficulty!)
   - ✅ Topics: Balance, Proportional Reasoning, Torque, Lever Arm, Rotational Equilibrium (5 tags)
   - ✅ 4 Learning Goals about balance and torque
   - ✅ Explanation about seesaws
3. Test fullscreen functionality
4. Verify you can place weights on the plank and see it tilt/balance

---

## ✅ Success Criteria

### Visual Quality
- [ ] All 4 cards display correctly with proper colors
- [ ] Orange PhET badge visible in section header
- [ ] Calculator icon (🔢) appears in badge
- [ ] Card gradients look smooth
- [ ] Text is readable and properly sized

### Functional Quality
- [ ] All 4 simulations load without black screens
- [ ] PhET Play buttons are visible and clickable
- [ ] Fullscreen mode works smoothly
- [ ] Rotation to landscape happens automatically
- [ ] Return to portrait works correctly
- [ ] All simulations are interactive (not static images)

### Content Quality
- [ ] All topics display as white rounded pills
- [ ] All learning goals have blue numbered circles
- [ ] Scientific explanations are readable
- [ ] Warning boxes appear with yellow background
- [ ] "Start Simulation" button is prominent

---

## 🐛 Known Issues & Solutions

### Issue: Black Screen
**Problem:** Simulation shows black screen instead of content  
**Solution:** Already fixed! If you still see it, try:
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Platform View Error
**Problem:** "Trying to create a platform view of unregistered type"  
**Solution:** This happens when adding new plugins. Stop the app and run:
```bash
flutter run
```
(Not hot reload - full restart needed)

### Issue: Simulations Not Interactive
**Problem:** Can see simulation but can't interact  
**Solution:** Check internet permissions in `AndroidManifest.xml` and `Info.plist` (already added)

---

## 📊 Comparison: Science vs Math

| Feature | Science Simulations | Math Simulations |
|---------|-------------------|------------------|
| **Count** | 3 simulations | 4 simulations |
| **Badge Color** | Blue | Orange |
| **Icon** | Science (🔬) | Calculator (🔢) |
| **Subtitle** | "Explore science concepts through interactive experiments" | "Master math concepts through interactive visualizations" |
| **Average Duration** | 16 mins | 18 mins |
| **Difficulty Range** | All "Easy Peasy" | Mostly "Easy Peasy", 1 "Medium" |

---

## 🎯 Quick Test Checklist

Copy this list and check off as you test:

```
Science Simulations:
 [ ] States of Matter loads and works
 [ ] Balloons & Static Electricity loads and works
 [ ] Exploring Density loads and works

Math Simulations:
 [ ] Equality Explorer: Basics loads and works
 [ ] Area Model Introduction loads and works
 [ ] Mean: Share and Balance loads and works
 [ ] Balancing Act loads and works

Fullscreen (test on 1-2 simulations):
 [ ] Enters fullscreen smoothly
 [ ] Rotates to landscape
 [ ] Exits fullscreen properly
 [ ] Returns to portrait

Navigation:
 [ ] Can navigate between simulations
 [ ] Back button returns to dashboard
 [ ] Dashboard shows both sections correctly
```

---

## 🎨 Screenshot Guide

When taking screenshots for documentation:

1. **Dashboard View:**
   - Capture both Science and Math sections in one screenshot
   - Show the orange Math badge clearly

2. **Math Section Close-up:**
   - Capture just the Math simulations grid
   - Show all 4 cards with their colors

3. **Detail Screen:**
   - Capture one full detail screen (scrolled to show all sections)
   - Include title bar, topics, learning goals, explanation, warning, and button

4. **Fullscreen:**
   - Capture one simulation in fullscreen landscape mode
   - Show interactive elements (e.g., balance scale with weights)

---

## 🚨 Emergency Rollback

If something breaks, you can temporarily hide the Math section:

In `bright_dashboard_screen.dart`, comment out these lines:

```dart
// const SizedBox(height: JuniorTheme.spacingLarge),
// _buildMathSimulationsSection(),
```

This will hide Math simulations but keep Science working.

---

## 📞 Need Help?

If you encounter issues:

1. **Check Terminal Output:** Look for errors mentioning "simulation" or "webview"
2. **Check Webview Console:** Look for "WebView Console: ..." messages
3. **Try Full Rebuild:** `flutter clean && flutter pub get && flutter run`
4. **Check Internet:** Ensure device/emulator has internet access
5. **Check PhET URLs:** Open URLs in browser to verify they're accessible

---

**Happy Testing! 🎉**

The Math simulations are ready to help Bright children explore equations, multiplication, averages, and balance through interactive PhET simulations.

