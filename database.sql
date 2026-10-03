CREATE TABLE IF NOT EXISTS radio_channels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    frequency FLOAT NOT NULL
);

CREATE TABLE IF NOT EXISTS player_radios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_id INT NOT NULL,
    channel_id INT NOT NULL,
    FOREIGN KEY (player_id) REFERENCES users(identifier),
    FOREIGN KEY (channel_id) REFERENCES radio_channels(id)
);

-- Insert default channels
INSERT INTO radio_channels (name, frequency) VALUES
('Radio Channel 1', 1.0),
('Radio Channel 2', 2.0),
('Radio Channel 3', 3.0);