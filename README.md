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
 

![WhatsApp Image 2025-06-29 at 11 44 04 PM](https://github.com/user-attachments/assets/3a369b34-02a6-43cd-bda0-6fe80383a643)
![WhatsApp Image 2025-06-29 at 11 44 05 PM](https://github.com/user-attachments/assets/c46ac622-8c6f-491a-800b-2f3570f0132b)
![WhatsApp Image 2025-06-29 at 11 44 05 PM (1)](https://github.com/user-attachments/assets/3576dc29-8208-452d-9ba3-4490c178e4e9)
![WhatsApp Image 2025-06-29 at 11 44 06 PM](https://github.com/user-attachments/assets/70e7a005-6522-4b0f-8f06-e2c25adca583)
![WhatsApp Image 2025-06-29 at 11 44 07 PM](https://github.com/user-attachments/assets/b0ae0ae7-4510-43cf-b1e1-67ceed99b6ca)
![WhatsApp Image 2025-06-29 at 11 44 07 PM (1)](https://github.com/user-attachments/assets/8d853cb6-cfb7-4a38-ab4b-fdaa23c12d55)
![WhatsApp Image 2025-06-29 at 11 44 07 PM (2)](ht![WhatsApp Image 2025-06-29 at 11 44 09 PM](https://github.com/user-attachments/assets/082b41dc-65cb-4138-99a7-c1b5eec03a81)
tps://github.com/user-attachments/assets/adb4b36a-eeab-4b49-92ce-d32a8c210b3e)
