# Firestore Indexes (Safeplay Mobile)

Collections:
- activities
- questionTemplates

Composite Indexes (examples to add in Firebase console):

activities:
- ageGroup ASC, subject ASC, published ASC
- ageGroup ASC, publishState ASC, updatedAt DESC
- ageGroup ASC, skills ARRAY_CONTAINS, updatedAt DESC
- ageGroup ASC, tags ARRAY_CONTAINS, updatedAt DESC

questionTemplates:
- title ASC
- type ASC, title ASC
- skills ARRAY_CONTAINS, title ASC

Single-field index overrides:
- Ensure `updatedAt` and `createdAt` are indexed for ordering.

Notes:
- ARRAY_CONTAINS composite indexes may require separate indexes per filter if combining with other fields.
- Disable indexing for large text fields if any are added later (none currently required).

