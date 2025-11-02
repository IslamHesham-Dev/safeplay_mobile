# Firestore Security Rules Update for Junior Children Games

## Issue
Junior children are getting `PERMISSION_DENIED` errors when trying to:
1. Read from `questionTemplates` collection
2. Read from `activities` collection

This prevents games from loading on the junior dashboard.

## Root Cause
The current Firestore security rules require authentication (`request.auth != null`), but junior children might not be properly authenticated as Firebase Auth users, or the rules need to explicitly allow children to read published content.

## Solution: Update Firestore Security Rules

You need to add rules that allow children (and authenticated users) to read:
- Published question templates for their age group
- Published activities for their age group

### Step 1: Go to Firebase Console

1. Open [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Firestore Database** → **Rules**

### Step 2: Add Rules for Question Templates

Add this rule **before** the catch-all rule at the end:

```javascript
// Question templates - allow children to read active templates for their age group
match /questionTemplates/{templateId} {
  // Allow read if:
  // 1. User is authenticated AND template is active
  // 2. OR if you want unauthenticated reads (for children with picture passwords):
  allow read: if resource.data.isActive == true;
  
  // Allow write only for authenticated users (teachers/admins)
  allow write: if request.auth != null;
}
```

**OR** if you want to restrict by age group (more secure):

```javascript
// Question templates - allow reading active templates matching user's age group
match /questionTemplates/{templateId} {
  allow read: if resource.data.isActive == true &&
    // Allow read if ageGroups array contains 'junior' or 'bright'
    (resource.data.ageGroups is list && 
     ('junior' in resource.data.ageGroups || 
      'bright' in resource.data.ageGroups));
  
  allow write: if request.auth != null;
}
```

### Step 3: Update Activities Rules

Update the existing `activities` rule to ensure published activities are readable:

```javascript
// Activities - allow children to read published activities
match /activities/{activityId} {
  // Allow read if:
  // 1. Activity is published AND matches age group
  // 2. OR user is authenticated (for teachers/parents)
  allow read: if 
    (resource.data.published == true && 
     resource.data.publishState == 'published') ||
    request.auth != null;
  
  // Allow write only for authenticated users (teachers/admins)
  allow write: if request.auth != null;
}
```

**OR** more restrictive (only published activities for specific age groups):

```javascript
// Activities - allow reading published activities
match /activities/{activityId} {
  allow read: if 
    resource.data.published == true && 
    resource.data.publishState == 'published' &&
    resource.data.ageGroup in ['junior', 'bright'];
  
  allow write: if request.auth != null;
}
```

### Step 4: Complete Rules Example

Here's how your complete rules section should look:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // ... existing rules for users, children, etc. ...
    
    // Question templates - allow reading active templates
    match /questionTemplates/{templateId} {
      // Allow read if template is active (published)
      allow read: if resource.data.isActive == true &&
        (resource.data.ageGroups is list && 
         ('junior' in resource.data.ageGroups || 
          'bright' in resource.data.ageGroups));
      
      // Allow write only for authenticated users (teachers/admins)
      allow write: if request.auth != null;
    }
    
    // Activities - allow reading published activities
    match /activities/{activityId} {
      // Allow read if published and matches age group
      allow read: if 
        resource.data.published == true && 
        resource.data.publishState == 'published' &&
        resource.data.ageGroup in ['junior', 'bright'];
      
      // Allow write only for authenticated users (teachers/admins)
      allow write: if request.auth != null;
    }
    
    // ... rest of your existing rules ...
  }
}
```

## Important Notes

### Option 1: Public Read Access (Easier)
If you use `allow read: if resource.data.isActive == true;` without authentication check, this allows **anyone** (including unauthenticated users) to read published templates. This is simpler but less secure.

### Option 2: Authenticated Only (More Secure)
If you require `request.auth != null`, you must ensure:
- Children are properly authenticated as Firebase Auth users when they log in
- Picture password authentication creates a Firebase Auth session
- Or use a custom authentication flow

### Option 3: Hybrid Approach (Recommended)
Use rules that check both authentication AND content status:
```javascript
allow read: if (request.auth != null || 
                (resource.data.isActive == true && 
                 resource.data.ageGroups is list));
```

## Testing After Update

1. **Wait 1-2 minutes** for rules to propagate
2. **Restart the app** completely
3. **Log in as a junior child**
4. **Check the dashboard** - games should now load
5. **Click on a game** - it should launch and load questions

## Troubleshooting

### Still Getting Permission Denied?

1. **Check Rules Syntax**: Make sure there are no syntax errors in Firebase Console
2. **Verify Data Structure**: Ensure your templates/activities have:
   - `isActive: true` (for templates)
   - `published: true` and `publishState: 'published'` (for activities)
   - `ageGroups: ['junior']` or `['bright']` in the array
3. **Check Authentication**: If using authenticated rules, verify child is logged in:
   - Check Firebase Console → Authentication
   - Verify child has an active session
4. **Clear App Cache**: Try clearing app data and logging in again
5. **Check Firestore Console**: Verify documents exist with correct fields

### For Production

For production, you should:
1. Restrict write access to teachers/admins only:
   ```javascript
   allow write: if request.auth != null && 
     (request.auth.token.role == 'teacher' || 
      request.auth.token.role == 'admin');
   ```

2. Add more specific age group checks:
   ```javascript
   allow read: if resource.data.isActive == true &&
     resource.data.ageGroups is list &&
     resource.data.ageGroups.hasAny(['junior', 'bright']);
   ```

## Quick Fix (Temporary)

If you need games to work immediately while updating rules, you can temporarily allow public reads:

```javascript
// TEMPORARY - REMOVE IN PRODUCTION
match /questionTemplates/{templateId} {
  allow read: if true;  // Allows anyone to read
  allow write: if request.auth != null;
}

match /activities/{activityId} {
  allow read: if true;  // Allows anyone to read
  allow write: if request.auth != null;
}
```

**⚠️ WARNING**: This makes all templates and activities publicly readable. Only use for testing, then update to the secure rules above.

## Next Steps

1. Update Firestore rules as described above
2. Test with a junior child account
3. Verify games load on dashboard
4. Verify games can launch and load questions
5. If everything works, consider adding more restrictive rules for production

