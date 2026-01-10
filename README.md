# Campus Care - Kampüs Yönetim Sistemi

Firebase Firestore tabanlı kampüs yönetim ve bakım takip sistemi.

## 📋 İçindekiler
- [Özellikler](#özellikler)
- [Veritabanı Yapısı](#veritabanı-yapısı)
- [Kurulum](#kurulum)

## 🚀 Özellikler

- ✅ Kullanıcı yönetimi (öğrenci, personel, admin)
- ✅ Bakım talep sistemi
- ✅ Etkinlik yönetimi
- ✅ Duyuru sistemi
- ✅ Demirbaş takibi
- ✅ Yorum ve değerlendirme sistemi

## 📊 Veritabanı Yapısı

### ER Diyagramı

```mermaid
erDiagram
    users ||--o{ announcements : creates
    users ||--o{ events : creates
    users ||--o{ comments : writes
    users ||--o{ ratings : gives
    users ||--o{ maintenanceRequests : submits
    users }o--|| departments : "belongs to"
    users ||--o{ academic_calendars : creates
    users ||--o{ demirbaslar : creates
    departments ||--o{ personel : employs
    departments ||--o{ demirbaslar : owns
    events ||--o{ comments : receives
    maintenanceRequests ||--o{ comments : receives
    maintenanceRequests ||--o{ ratings : receives
    users {
        string id PK
        string email UK
        string name
        string roleId
        string departmentId FK
        string phone
        string photoUrl
        timestamp createdAt
        timestamp updatedAt
    }
    departments {
        string id PK
        string name UK
        string description
        string campusId
        string managerId FK
    }
    personel {
        string id PK
        string name
        string email
        string phone
        string department
        string position
        boolean isActive
        timestamp createdAt
    }
    academic_calendars {
        string id PK
        string title
        string description
        string startDate
        string endDate
        string type
        string createdById FK
        string createdAt
    }
    events {
        string id PK
        string title
        string description
        timestamp eventDate
        string location
        number latitude
        number longitude
        string createdById FK
        string createdByName
        array photoUrls
        boolean isActive
        timestamp createdAt
    }
    announcements {
        string id PK
        string title
        string content
        string authorId FK
        string authorName
        array photoUrls
        boolean isActive
        timestamp createdAt
        timestamp updatedAt
    }
    comments {
        string id PK
        string text
        string userId FK
        string requestId FK
        timestamp createdAt
    }
    ratings {
        string id PK
        number rating
        string comment
        string userId FK
        string requestId FK
        timestamp createdAt
    }
    maintenanceRequests {
        string id PK
        string title
        string description
        string priority
        string status
        string userId FK
        string roomId
        string categoryId
        string locationId
        array photoUrls
        string adminNote
        timestamp createdAt
        timestamp updatedAt
        timestamp completedAt
    }
    demirbaslar {
        string id PK
        string name
        string description
        number quantity
        string createdById FK
        string createdAt
    }
```

### 📚 Collections (13 Tablo)

| Collection | Açıklama | İlişkiler |
|------------|----------|-----------|
| **users** | Kullanıcı bilgileri | departments (N:1) |
| **departments** | Bölüm bilgileri | - |
| **personel** | Personel kayıtları | users (N:1), departments (N:1) |
| **academic_calendars** | Akademik takvim | users (N:1) |
| **events** | Etkinlikler | users (N:1), comments (1:N) |
| **announcements** | Duyurular | users (N:1), comments (1:N) |
| **comments** | Yorumlar | users (N:1), maintenanceRequests (N:1) |
| **ratings** | Değerlendirmeler | users (N:1), maintenanceRequests (N:1) |
| **maintenanceRequests** | Bakım talepleri | users (N:1), rooms (N:1), categories (N:1) |
| **demirbaslar** | Demirbaş/Envanter | users (N:1), departments (N:1) |

### 🔑 Anahtar Özellikler

- **Primary Keys (PK)**: Her tabloda unique `id` alanı
- **Foreign Keys (FK)**: İlişkisel referanslar
- **Unique Keys (UK)**: Email, code gibi tekil alanlar
- **Timestamps**: Tüm işlemler zaman damgalı

## 🛠️ Kurulum

```bash
# Repository'yi klonlayın
git clone https://github.com/kullanici-adi/campus-care.git

# Bağımlılıkları yükleyin
npm install

# Firebase yapılandırması
# .env dosyasını oluşturun ve Firebase credentials'ı ekleyin

# Uygulamayı başlatın
npm start
```

## 📱 Teknolojiler

- Firebase Firestore (NoSQL Database)
- React Native / Flutter (Mobile)
- Node.js (Backend - opsiyonel)

