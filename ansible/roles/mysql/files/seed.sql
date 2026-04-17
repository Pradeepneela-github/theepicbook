-- EpicBook Database Seed File (reference structure only)
-- YOUR actual files already exist in your repo at:
--   db/author_seed.sql   — your real author data
--   db/books_seed.sql    — your real book data
--   db/BuyTheBook_Schema.sql — your table definitions
--
-- HOW THEY GET TO THE SERVER (no copy needed):
-- The epicbook role clones the full repo to {{ app_dest }} on the VM.
-- The mysql role then reads from {{ app_dest }}/db/ directly using
-- the mysql CLI. Your db/ folder travels with the app automatically.
-- You do NOT need to move or copy these files anywhere.

-- Create tables
CREATE TABLE IF NOT EXISTS books (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    title       VARCHAR(255)  NOT NULL,
    author      VARCHAR(255)  NOT NULL,
    genre       VARCHAR(100),
    isbn        VARCHAR(20)   UNIQUE,
    published_year INT,
    description TEXT,
    cover_url   VARCHAR(500),
    created_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    username    VARCHAR(100)  UNIQUE NOT NULL,
    email       VARCHAR(255)  UNIQUE NOT NULL,
    created_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reading_list (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT NOT NULL,
    book_id     INT NOT NULL,
    status      ENUM('want_to_read','reading','completed') DEFAULT 'want_to_read',
    added_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- Seed real book data
-- INSERT IGNORE prevents errors if the pipeline runs more than once
INSERT IGNORE INTO books (title, author, genre, isbn, published_year, description) VALUES
('The Hitchhiker''s Guide to the Galaxy', 'Douglas Adams', 'Science Fiction', '978-0345391803', 1979, 'A comedic science fiction series following the misadventures of the last surviving man after Earth is demolished.'),
('Dune', 'Frank Herbert', 'Science Fiction', '978-0441013593', 1965, 'A saga of a desert planet, interstellar politics, and the hero Paul Atreides.'),
('1984', 'George Orwell', 'Dystopian', '978-0451524935', 1949, 'A terrifying vision of a totalitarian society and the destruction of truth.'),
('To Kill a Mockingbird', 'Harper Lee', 'Fiction', '978-0061935466', 1960, 'A story of racial injustice and moral growth seen through the eyes of a young girl in the American South.'),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction', '978-0743273565', 1925, 'A portrait of the American Dream and its hollowness in the Jazz Age.'),
('The Pragmatic Programmer', 'David Thomas & Andrew Hunt', 'Technology', '978-0135957059', 2019, 'Practical advice for software developers on how to write better code and build better careers.'),
('Clean Code', 'Robert C. Martin', 'Technology', '978-0132350884', 2008, 'A handbook of agile software craftsmanship with principles, patterns, and practices of writing clean code.'),
('The DevOps Handbook', 'Gene Kim et al.', 'Technology', '978-1950508402', 2021, 'How to create world-class agility, reliability, and security in technology organizations.'),
('Sapiens', 'Yuval Noah Harari', 'Non-Fiction', '978-0062316097', 2011, 'A brief history of humankind from the Stone Age to the present.'),
('Atomic Habits', 'James Clear', 'Self-Help', '978-0735211292', 2018, 'A practical guide to building good habits and breaking bad ones using tiny changes.');

-- Seed a demo user
INSERT IGNORE INTO users (username, email) VALUES
('demo_user', 'demo@epicbook.local');
