CREATE TABLE messages (
  id            BIGSERIAL PRIMARY KEY,
  sender_id     BIGINT NOT NULL,
  receiver_id   BIGINT, -- not null for direct messages
  channel_id    BIGINT, -- not null for group chat in a channel
  content       TEXT,
  created_at    TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (sender_id)   REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (channel_id)  REFERENCES channels(id) ON DELETE CASCADE
);

ALTER TABLE messages
  ADD CONSTRAINT check_direct_or_channel
  CHECK (
    (receiver_id IS NOT NULL AND channel_id IS NULL)
    OR (receiver_id IS NULL AND channel_id IS NOT NULL)
  );
