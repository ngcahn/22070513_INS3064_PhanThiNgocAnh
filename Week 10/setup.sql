CREATE DATABASE IF NOT EXISTS contact_manager
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE contact_manager;

CREATE TABLE IF NOT EXISTS contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    group_name VARCHAR(50) DEFAULT 'General',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO contacts (name, email, phone, group_name, notes) VALUES
('Nguyen Van An', 'an.nguyen@example.com', '0901234567', 'Friends', 'University friend'),
('Tran Thi Binh', 'binh.tran@example.com', '0912345678', 'Family', 'Family contact'),
('Le Minh Chau', 'chau.le@example.com', '0987654321', 'Work', 'Project colleague'),
('Pham Quang Duy', 'duy.pham@example.com', '0934567890', 'Other', 'Met at an event'),
('Hoang Thu Ha', 'ha.hoang@example.com', '0965432109', 'General', 'General contact');
