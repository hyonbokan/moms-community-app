CREATE TABLE notifications (
  id           BIGSERIAL PRIMARY KEY,
  user_id      BIGINT NOT NULL, -- The recipient of the notification
  type         VARCHAR(50) NOT NULL, -- 'LIKE', 'COMMENT', 'MESSAGE', 'FRIEND_REQUEST'
  post_id      BIGINT, -- for likes/comments
  sender_id    BIGINT, -- the user who triggered the notification
  message_id   BIGINT, -- if it's a new message
  created_at   TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  seen         BOOLEAN DEFAULT FALSE,

  FOREIGN KEY (user_id)   REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (post_id)   REFERENCES posts(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (message_id) REFERENCES messages(id) ON DELETE CASCADE
);
