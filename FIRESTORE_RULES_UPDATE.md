# Firestore Rules Update for Question Templates Export

## Issue
When trying to export question templates from Firebase, you're getting:
```
Error: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

## Solution

The Firestore security rules need to be updated to allow reading from the `questionTemplates` collection.

### Option 1: Update Rules in Firebase Console (Quickest)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (`safeplay-portal`)
3. Navigate to **Firestore Database** → **Rules**
4. Add this rule before the default catch-all rule:

```javascript
// Question templates - allow authenticated users to read
match /questionTemplates/{templateId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null;
}
```

5. Click **Publish**

### Option 2: Deploy Rules from File

If you have the Firebase CLI installed:

```bash
cd safeplay-web
firebase deploy --only firestore:rules
```

The updated `firestore.rules` file already includes the `questionTemplates` rule.

## Important Notes

1. **Authentication Required**: Make sure you're logged in when trying to export. The widget requires authentication to access Firestore.

2. **Current Rules**: The rules already have a catch-all at the end that should allow authenticated reads, but explicitly adding the rule for `questionTemplates` ensures it works correctly.

3. **For Production**: Consider restricting write access to admins only:
```javascript
match /questionTemplates/{templateId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.token.admin == true;
}
```

## Testing

After updating the rules:
1. Make sure you're logged into the app
2. Navigate to the Export widget (via Achievements/Notifications screen)
3. Click "Export to JSON"
4. The export should now work without permission errors

## Troubleshooting

If you still get permission errors:
1. **Check authentication**: Make sure you're logged in as a user
2. **Wait a few seconds**: Rules deployment can take a minute to propagate
3. **Check Firebase Console**: Verify the rules were published correctly
4. **Try logging out and back in**: This refreshes the auth token






