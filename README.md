# 📚 BlogsPado - A Flutter Blog App with Social Features

BlogsPado is a modern Flutter + Firebase-powered blog app where users can share posts, explore blogs by others, comment, like, and follow authors. It includes markdown editing, real-time updates, and Firebase Authentication with Firestore as backend.

---

## 🚀 Features

- 🔐 Firebase Authentication (Email/Password & Google Sign-In on Mobile)
- 📝 Create/Edit/Delete blogs with Markdown-style content
- 📂 Explore all blogs and switch to Following tab
- ❤️ Like posts with real-time like count
- 💬 Comment on blog posts with real-time updates
- 👥 Follow/Unfollow other users
- 🧭 Category filters and search functionality
- 📶 Firestore-backed real-time sync
- 🧠 State management using Provider

---

## 🔐 Authentication Flow

- Users can **sign up or log in** with email and password
- Mobile-only support for **Google Sign-In**
- Only authenticated users can:
  - Create/Edit/Delete their blogs
  - Comment and Like
  - Follow/Unfollow other users

---

## 🧱 Firestore Data Structure

### 📄 `users` Collection

| Field | Type | Description |
|---|---|---|
| `uid` | String | Firebase UID |
| `username` | String | Display name |
| `email` | String | User email |
| `profilePicUrl` | String | Local asset path |
| `followers` | List | UID list of followers |
| `following` | List | UID list of followed users |

---

### 📄 `blogs` Collection

| Field | Type | Description |
|---|---|---|
| `blogId` | String | Auto-generated doc ID |
| `authorId` | String | Blog author's UID |
| `authorName` | String | Author name |
| `authorPhotoUrl` | String | Asset path |
| `title` | String | Blog title |
| `description` | String | Short blog summary |
| `content` | String | Markdown content |
| `category` | String | Blog category |
| `timestamp` | DateTime | Creation time |
| `likes` | List | UID list of users who liked |
| `isPinned` | Boolean | Optional pin flag |

---

### 📄 `blogs/{blogId}/comments` Subcollection

| Field | Type | Description |
|---|---|---|
| `commentId` | String | Auto-generated |
| `commenterId` | String | UID of the user |
| `content` | String | Comment text |
| `timestamp` | DateTime | Time of comment |

---

---

## 🔥 Firestore Rules

```js
 rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
  allow read: if true;

  // ✅ Allow updating own document (e.g. 'following' array)
  allow update: if request.auth != null && request.auth.uid == userId;

  // ✅ Allow other users to update only the 'followers' field
  allow update: if request.auth != null &&
    request.resource.data.diff(resource.data).changedKeys().hasOnly(["followers"]);
    
  // ✅ Allow creating own user document (e.g. on signup)
  allow write: if request.auth != null && request.auth.uid == userId;
}

    // Blogs collection
    match /blogs/{blogId} {
      allow read: if true;

      // Allow anyone to create if they are the author
      allow create: if request.auth != null
        && request.resource.data.authorId == request.auth.uid;

      // Allow full update/delete if user is author
      allow update, delete: if request.auth != null
        && request.auth.uid == resource.data.authorId;

      // Allow like updates for others — only if updating `likes` array
      allow update: if request.auth != null
        && request.resource.data.diff(resource.data).changedKeys().hasOnly(["likes"]);

      // Comments subcollection
      match /comments/{commentId} {
        allow read: if true;

        allow create: if request.auth != null
          && request.resource.data.commenterId == request.auth.uid;

        allow delete: if request.auth != null
          && (
            request.auth.uid == resource.data.commenterId ||  // Comment author
            request.auth.uid == get(/databases/$(database)/documents/blogs/$(blogId)).data.authorId  // Blog owner
          );
      }
    }
  }
}
 

