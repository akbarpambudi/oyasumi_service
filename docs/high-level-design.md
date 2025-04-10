# High-Level Design

## Entities

### User
- **Fields:** `id`, `name`, `email`
- A user can have many “followings” and many “followers.”

### Relationship (for "follow"/"unfollow")
- Joins two `User` records.
- **follower_id**: the user who follows
- **followed_id**: the user being followed

### SleepRecord
- Tracks a user’s sleep.
- **user_id**: belongs to a user
- **start_time**: when the user goes to bed
- **end_time**: when the user wakes up (can be `NULL` until clock out if you prefer that flow)

---

## Assumptions and Clarifications

- **Clock In**: Create a `SleepRecord` with `start_time = Time.current`.
- **Clock Out**: Commonly, you’d update the same record’s `end_time`. The requirement only explicitly mentions “Clock In operation, and return all clocked-in times,” but real-world usage typically includes a separate “clock out” flow.
- **Listing Sleep Records**:
    - `GET /sleep_records` retrieves all your sleep records, ordered by creation time.
- **Following**:
    - `POST /users/me/follow/:user_id` to follow.
    - `DELETE /users/me/follow/:user_id` to unfollow.
- **See Sleep Records of All Followed Users (last week)**:
    - `GET /users/me/following_sleep_records` returns the sleep records from the previous 7 days of all users that `:id` follows. These are sorted by duration (`end_time - start_time`).

---

## Performance and Concurrency Considerations

### Database Indexes
- Index `relationships` on (`follower_id`, `followed_id`) for quick lookups.
- Index `sleep_records` on `user_id` for efficient queries.
- Consider adding an index on (`user_id`, `start_time`, `end_time`) if you frequently query by time windows.

### Caching & Pagination
- For large-scale usage, retrieving all records might be expensive. Consider pagination (offset or cursor).
- Cache “sleep records from the last week” if frequently requested.

### Concurrency
- Use database transactions for critical consistency.
- For extremely high concurrency, you could offload reporting (like sorting large volumes by duration) to background jobs or specialized data stores.

### Sharding or Partitioning
- For significant user growth, consider sharding by user or partitioning by time ranges.
- For moderate usage, straightforward indexing and standard queries may suffice.
