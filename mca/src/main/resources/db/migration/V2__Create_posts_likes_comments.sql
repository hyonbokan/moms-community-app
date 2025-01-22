CREATE TABLE posts (
  id           BIGSERIAL PRIMARY KEY,
  user_id      BIGINT NOT NULL, -- post author
  channel_id   BIGINT,          -- nullable (if not posted in a channel)
  content      TEXT,
  image_url    VARCHAR(255),    -- for optional images
  share_post_id BIGINT,         -- to track post sharing
  created_at   TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (channel_id) REFERENCES channels(id) ON DELETE SET NULL,
  FOREIGN KEY (share_post_id) REFERENCES posts(id) ON DELETE CASCADE
);

CREATE TABLE likes (
  user_id BIGINT NOT NULL,
  post_id BIGINT NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (user_id, post_id),
  FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(id)  ON DELETE CASCADE
);

CREATE TABLE comments (
  id         BIGSERIAL PRIMARY KEY,
  user_id    BIGINT NOT NULL,
  post_id    BIGINT NOT NULL,
  content    TEXT NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE
);
