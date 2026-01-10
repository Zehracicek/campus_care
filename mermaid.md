erDiagram
    users ||--o{ announcements : creates
    users ||--o{ events : creates
    users ||--o{ comments : writes
    users ||--o{ ratings : gives
    users ||--o{ maintenanceRequests : submits
    users }o--|| departments : "belongs to"
    departments ||--o{ personel : employs
    departments ||--o{ demirbaslar : owns
    events ||--o{ comments : receives
    maintenanceRequests ||--o{ comments : receives
    maintenanceRequests ||--o{ ratings : receives
    maintenanceRequests }o--|| rooms : "located in"
    maintenanceRequests }o--|| categories : "belongs to"
    academic_calendars }o--|| users : "created by"
    events }o--|| users : "created by"
    announcements }o--|| users : "authored by"
    demirbaslar }o--|| users : "created by"
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
        string roomId FK
        string categoryId FK
        string locationId
        array photoUrls
        string adminNote
        timestamp createdAt
        timestamp updatedAt
        timestamp completedAt
    }
    rooms {
        string id PK
        string roomNumber
        string building
        string floor
        string departmentId FK
    }
    categories {
        string id PK
        string name
        string description
    }
    demirbaslar {
        string id PK
        string name
        string description
        number quantity
        string createdById FK
        string createdAt
    }
    notifications {
        string id PK
        string userId FK
        string title
        string message
        string type
        boolean isRead
        timestamp createdAt
    }
