# Firestore Indexes for New Features

This document outlines the required Firestore indexes for the new lesson management and progress tracking features.

## Collections and Required Indexes

### 1. `lessons` Collection

#### Single Field Indexes
- `ageGroupTarget` (Array) - e.g., ["6-8", "9-12"]
- `exerciseType` (String)
- `mappedGameType` (String)
- `subject` (String)
- `difficulty` (String)
- `isActive` (Boolean)
- `createdBy` (String)
- `createdAt` (Timestamp) - Descending
- `updatedAt` (Timestamp) - Descending

#### Composite Indexes
- `ageGroupTarget` (Array) - e.g., ["6-8", "9-12"] + `isActive` (Boolean) + `createdAt` (Timestamp) - Descending
- `exerciseType` (String) + `isActive` (Boolean) + `createdAt` (Timestamp) - Descending
- `mappedGameType` (String) + `isActive` (Boolean) + `createdAt` (Timestamp) - Descending
- `subject` (String) + `isActive` (Boolean) + `createdAt` (Timestamp) - Descending
- `difficulty` (String) + `isActive` (Boolean) + `createdAt` (Timestamp) - Descending
- `createdBy` (String) + `isActive` (Boolean) + `createdAt` (Timestamp) - Descending
- `ageGroupTarget` (Array) - e.g., ["6-8", "9-12"] + `exerciseType` (String) + `isActive` (Boolean)
- `ageGroupTarget` (Array) - e.g., ["6-8", "9-12"] + `mappedGameType` (String) + `isActive` (Boolean)
- `ageGroupTarget` (Array) - e.g., ["6-8", "9-12"] + `subject` (String) + `isActive` (Boolean)

### 2. `childrenProgress` Collection

#### Single Field Indexes
- `childId` (String)
- `earnedPoints` (Number) - Descending
- `lastActiveDate` (Timestamp) - Descending
- `totalTimeSpent` (Number) - Descending

#### Composite Indexes
- `earnedPoints` (Number) - Descending + `lastActiveDate` (Timestamp) - Descending
- `lastActiveDate` (Timestamp) - Descending + `earnedPoints` (Number) - Descending

### 3. `teacherAssignments` Collection

#### Single Field Indexes
- `teacherId` (String)
- `status` (String)
- `dueDate` (Timestamp) - Ascending
- `createdAt` (Timestamp) - Descending
- `updatedAt` (Timestamp) - Descending

#### Composite Indexes
- `teacherId` (String) + `status` (String) + `createdAt` (Timestamp) - Descending
- `teacherId` (String) + `status` (String) + `dueDate` (Timestamp) - Ascending
- `status` (String) + `dueDate` (Timestamp) - Ascending
- `status` (String) + `dueDate` (Timestamp) - Descending
- `childGroupIds` (Array) + `status` (String) + `dueDate` (Timestamp) - Ascending
- `lessonIds` (Array) + `status` (String) + `createdAt` (Timestamp) - Descending

### 4. `children` Collection (if not already exists)

#### Single Field Indexes
- `parentId` (String)
- `ageGroup` (String)
- `createdAt` (Timestamp) - Descending

#### Composite Indexes
- `parentId` (String) + `ageGroup` (String)
- `parentId` (String) + `createdAt` (Timestamp) - Descending

## Index Creation Commands

### Using Firebase CLI

```bash
# Lessons collection indexes
firebase firestore:indexes:create --collection=lessons --field=ageGroupTarget,isActive,createdAt
firebase firestore:indexes:create --collection=lessons --field=exerciseType,isActive,createdAt
firebase firestore:indexes:create --collection=lessons --field=mappedGameType,isActive,createdAt
firebase firestore:indexes:create --collection=lessons --field=subject,isActive,createdAt
firebase firestore:indexes:create --collection=lessons --field=difficulty,isActive,createdAt
firebase firestore:indexes:create --collection=lessons --field=createdBy,isActive,createdAt
firebase firestore:indexes:create --collection=lessons --field=ageGroupTarget,exerciseType,isActive
firebase firestore:indexes:create --collection=lessons --field=ageGroupTarget,mappedGameType,isActive
firebase firestore:indexes:create --collection=lessons --field=ageGroupTarget,subject,isActive

# Children Progress collection indexes
firebase firestore:indexes:create --collection=childrenProgress --field=earnedPoints,lastActiveDate

# Teacher Assignments collection indexes
firebase firestore:indexes:create --collection=teacherAssignments --field=teacherId,status,createdAt
firebase firestore:indexes:create --collection=teacherAssignments --field=teacherId,status,dueDate
firebase firestore:indexes:create --collection=teacherAssignments --field=status,dueDate
firebase firestore:indexes:create --collection=teacherAssignments --field=childGroupIds,status,dueDate
firebase firestore:indexes:create --collection=teacherAssignments --field=lessonIds,status,createdAt

# Children collection indexes (if needed)
firebase firestore:indexes:create --collection=children --field=parentId,ageGroup
firebase firestore:indexes:create --collection=children --field=parentId,createdAt
```

### Using Firebase Console

1. Go to Firebase Console → Firestore Database → Indexes
2. Click "Create Index"
3. Select the collection name
4. Add fields with their types and sort orders
5. Click "Create"

## Index Configuration File

Create a `firestore.indexes.json` file in your project root:

```json
{
  "indexes": [
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "ageGroupTarget",
          "arrayConfig": "CONTAINS"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "exerciseType",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "mappedGameType",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "subject",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "difficulty",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "createdBy",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "ageGroupTarget",
          "arrayConfig": "CONTAINS"
        },
        {
          "fieldPath": "exerciseType",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "ageGroupTarget",
          "arrayConfig": "CONTAINS"
        },
        {
          "fieldPath": "mappedGameType",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "lessons",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "ageGroupTarget",
          "arrayConfig": "CONTAINS"
        },
        {
          "fieldPath": "subject",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isActive",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "childrenProgress",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "earnedPoints",
          "order": "DESCENDING"
        },
        {
          "fieldPath": "lastActiveDate",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "teacherAssignments",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "teacherId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "teacherAssignments",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "teacherId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "dueDate",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "teacherAssignments",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "dueDate",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "teacherAssignments",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "childGroupIds",
          "arrayConfig": "CONTAINS"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "dueDate",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "teacherAssignments",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "lessonIds",
          "arrayConfig": "CONTAINS"
        },
        {
          "fieldPath": "status",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "children",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "parentId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "ageGroup",
          "order": "ASCENDING"
        }
      ]
    },
    {
      "collectionGroup": "children",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "parentId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    }
  ],
  "fieldOverrides": []
}
```

## Deployment

To deploy the indexes:

```bash
# Deploy indexes
firebase deploy --only firestore:indexes

# Or deploy everything including indexes
firebase deploy
```

## Notes

1. **Array Fields**: For fields like `ageGroupTarget`, `childGroupIds`, and `lessonIds`, use `arrayConfig: "CONTAINS"` instead of `order`.

2. **Query Optimization**: These indexes are designed to support the most common query patterns in the new services.

3. **Index Limits**: Firestore has limits on the number of indexes per project. Monitor your usage in the Firebase Console.

4. **Cost Consideration**: More indexes mean higher costs. Only create indexes for queries you actually use.

5. **Testing**: Test your queries in the Firebase Console before deploying to production to ensure indexes are working correctly.
