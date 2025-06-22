create database ProjectBiddingDB1;
USE ProjectBiddingDB1;
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(20) CHECK (role IN ('Client', 'Freelancer')),
    rating DECIMAL(3,2) DEFAULT 0.00
);
CREATE TABLE Skills (
    skill_id int PRIMARY KEY,
    skill_name VARCHAR(100) UNIQUE NOT NULL
);
CREATE TABLE Projects (
    project_id int PRIMARY KEY,
    client_id int,
    title VARCHAR(100),
    description text,
    budget decimal (10,2),
    deadline DATE,
    status VARCHAR(20) DEFAULT 'Open' CHECK (status IN ('Open', 'In Progress', 'Completed', 'Cancelled')),
    CONSTRAINT fk_client FOREIGN KEY (client_id) REFERENCES Users(user_id)
);
CREATE TABLE Bids (
    bid_id int PRIMARY KEY,
    project_id int,
    freelancer_id int,
    amount DEcimal(10,2),
    timeline_days int ,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Accepted', 'Rejected')),
    CONSTRAINT fk_proj FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    CONSTRAINT fk_freelancer FOREIGN KEY (freelancer_id) REFERENCES Users(user_id)
);

CREATE TABLE Freelancer_Skills (
    freelancer_id int,
    skill_id int,
    PRIMARY KEY (freelancer_id, skill_id),
    FOREIGN KEY (freelancer_id) REFERENCES Users(user_id),
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id)
);
CREATE TABLE Project_Skills (
    project_id int,
    skill_id int,
    PRIMARY KEY (project_id, skill_id),
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (skill_id) REFERENCES Skills(skill_id)
);
CREATE TABLE Reviews (
    review_id int PRIMARY KEY,
    reviewer_id int,
    reviewee_id int,
    project_id int,
    rating decimal(3,2),
    comment text,
    CONSTRAINT fk_reviewer FOREIGN KEY (reviewer_id) REFERENCES Users(user_id),
    CONSTRAINT fk_reviewee FOREIGN KEY (reviewee_id) REFERENCES Users(user_id),
    CONSTRAINT fk_review_proj FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);
INSERT INTO Users (user_id, name, email, role, rating) VALUES
(1, 'Alice', 'alice@example.com', 'Client', 4.5),
(2, 'Bob', 'bob@example.com', 'Freelancer', 4.8),
(3, 'Charlie', 'charlie@example.com', 'Freelancer', 4.2),
(4, 'Diana', 'diana@example.com', 'Client', 4.0);

INSERT INTO Projects (project_id, client_id, title, description, budget, deadline, status) VALUES
(101, 1, 'E-commerce Website', 'Build an e-commerce site using Spring Boot and React.', 50000, '2025-07-15', 'Open'),
(102, 4, 'Chatbot Integration', 'Integrate a chatbot using Java and NLP techniques.', 30000, '2025-07-01', 'Open');

INSERT INTO Bids (bid_id, project_id, freelancer_id, amount, timeline_days, status) VALUES
(201, 101, 2, 48000, 7, 'Pending'),
(202, 101, 3, 45000, 6, 'Pending'),
(203, 102, 3, 29000, 5, 'Pending');

INSERT INTO Skills (skill_id, skill_name) VALUES
(1, 'Java'),
(2, 'Spring Boot'),
(3, 'React'),
(4, 'MySQL'),
(5, 'NLP');

INSERT INTO Project_Skills (project_id, skill_id) VALUES
(101, 1), -- Java
(101, 2), -- Spring Boot
(101, 3), -- React
(102, 1), -- Java
(102, 5); -- NLP

DELIMITER //
USE ProjectBiddingDB;

DELIMITER //

CREATE PROCEDURE AcceptBid (IN p_bid_id INT)
BEGIN
    DECLARE v_project_id INT;

    -- Step 1: Get project_id from the Bids table
    SELECT project_id
    INTO v_project_id
    FROM Bids
    WHERE bid_id = p_bid_id;

    -- Step 2: Mark the selected bid as 'Accepted'
    UPDATE Bids
    SET status = 'Accepted'
    WHERE bid_id = p_bid_id;

    -- Step 3: Reject other bids for the same project
    UPDATE Bids
    SET status = 'Rejected'
    WHERE project_id = v_project_id AND bid_id != p_bid_id;

    -- Step 4: Update the project status to 'In Progress'
    UPDATE Projects
    SET status = 'In Progress'
    WHERE project_id = v_project_id;
END;
//

DELIMITER ;

CREATE VIEW Top_Freelancers AS
SELECT user_id, name, rating
FROM Users
WHERE role = 'Freelancer'
ORDER BY rating DESC
LIMIT 5;

SELECT project_id, COUNT(*) AS total_bids
FROM Bids
GROUP BY project_id
ORDER BY total_bids DESC
LIMIT 1;


SELECT freelancer_id, COUNT(*) AS assigned_projects
FROM Bids
WHERE status = 'Accepted'
GROUP BY freelancer_id
ORDER BY assigned_projects DESC;