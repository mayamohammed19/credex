CREATE DATABASE credex;
Use credex;

-- USERS TABLE
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    role VARCHAR(50) NOT NULL,
    username varchar(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_type ENUM('Business', 'Individual') NOT NULL
);

CREATE INDEX idx_role ON users(role);
CREATE INDEX idx_email ON users(email);


-- ADMIN TABLE
CREATE TABLE admin (
    admin_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


-- INDIVIDUAL QUESTIONS
CREATE TABLE individual_questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    question_text TEXT NOT NULL
);

-- INDIVIDUAL MCQ OPTIONS
CREATE TABLE ind_mcq_options (
    option_id INT PRIMARY KEY AUTO_INCREMENT,
    question_id INT NOT NULL,
    option_text VARCHAR(255) NOT NULL,
    FOREIGN KEY (question_id) REFERENCES individual_questions(question_id) ON DELETE CASCADE
);

CREATE INDEX idx_question_id ON ind_mcq_options(question_id);

-- INDIVIDUAL ANSWERS
CREATE TABLE individual_answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    option_id INT NULL,
    answer TEXT NULL,
    answered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES individual_questions(question_id) ON DELETE CASCADE,
    FOREIGN KEY (option_id) REFERENCES ind_mcq_options(option_id) ON DELETE CASCADE
);

CREATE INDEX idx_user_id ON individual_answers(user_id);
CREATE INDEX idx_question_id ON individual_answers(question_id);

-- BUSINESS NON-FINANCIAL QUESTIONS
CREATE TABLE bus_nonfin_questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    question_text TEXT NOT NULL,
    question_category VARCHAR(100) NOT NULL
);

-- BUSINESS NON-FINANCIAL ANSWERS
CREATE TABLE bus_nonfin_answers (
    answer_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    mcq_options VARCHAR(255) NULL,
    answer TEXT NULL,
    answered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES bus_nonfin_questions(question_id) ON DELETE CASCADE
);

CREATE INDEX idx_bus_user_id ON bus_nonfin_answers(user_id);
CREATE INDEX idx_bus_question_id ON bus_nonfin_answers(question_id);

-- BUSINESS FINANCIAL STATEMENTS
CREATE TABLE bus_financial_statements (
    statement_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    statement_type VARCHAR(50) NOT NULL,
    statement_period DATE NOT NULL,
    uploaded_filedata BLOB NULL,
    validation_results VARCHAR(255) NULL,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_bus_fin_user_id ON bus_financial_statements(user_id);

-- BUSINESS FINANCIAL DATA
CREATE TABLE bus_financial_data (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    statement_id INT NOT NULL,
    total_debt DECIMAL(15,2) NOT NULL CHECK (total_debt >= 0),
    total_equity DECIMAL(15,2) NOT NULL CHECK (total_equity >= 0),
    current_assets DECIMAL(15,2) NOT NULL CHECK (current_assets >= 0),
    revenue DECIMAL(15,2) NOT NULL CHECK (revenue >= 0),
    interest_expenses DECIMAL(15,2) NOT NULL CHECK (interest_expenses >= 0),
    current_liab DECIMAL(15,2) NOT NULL CHECK (current_liab >= 0),
    ebit DECIMAL(15,2) NOT NULL,
    cogs DECIMAL(15,2) NOT NULL CHECK (cogs >= 0),
    inventory DECIMAL(15,2) NOT NULL CHECK (inventory >= 0),
    total_assets DECIMAL(15,2) NOT NULL CHECK (total_assets >= 0),
    net_income DECIMAL(15,2),
    z_score DECIMAL(10,2),
    calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (statement_id) REFERENCES bus_financial_statements(statement_id) ON DELETE CASCADE
);

CREATE INDEX idx_bus_fin_data_user_id ON bus_financial_data(user_id);

-- SCORE HISTORY
CREATE TABLE score_history (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    snapshot_id INT NULL,
    recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_current BOOLEAN NOT NULL DEFAULT FALSE,
    financial_score DECIMAL(10,2) NULL,
    nonfinancial_score DECIMAL(10,2) NULL,
    individual_score DECIMAL(10,2) NULL,
    total_score DECIMAL(10,2) NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_score_user_id ON score_history(user_id);


-- Ensures that when a new score is added, previous records are marked as FALSE
CREATE TRIGGER before_insert_score
BEFORE INSERT ON score_history
FOR EACH ROW
UPDATE score_history SET is_current = FALSE WHERE user_id = NEW.user_id;
