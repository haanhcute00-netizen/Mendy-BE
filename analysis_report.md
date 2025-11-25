# Analysis Report: Chat & Bookings Modules vs Database Schema

## Overview
Analyzed `src/modules/chat`, `src/modules/bookings`, and `newupdate.sql` to verify functionality and consistency between the codebase and the database schema.

## Critical Findings

### 1. Missing Database Tables
The following tables are used in the code but are **missing** from `newupdate.sql`:

*   **`app.chat_attachments`**
    *   **Used in:** `src/modules/chat/chat.repo.js` (line 64)
    *   **Functionality:** Storing file attachments for chat messages.
    *   **Impact:** Sending messages with attachments will fail with a "relation does not exist" error.

*   **`app.chat_thread_invitations`**
    *   **Used in:** `src/modules/chat/chat.repo.js` (line 177, 187, 197, 202)
    *   **Functionality:** Managing invitations for group chats.
    *   **Impact:** Creating group chats or inviting members will fail.

### 2. Invalid Enum Value Usage
*   **`app.payment_status`**
    *   **Issue:** `src/modules/bookings/bookingPayment.service.js` (lines 389, 435) attempts to update payment status to `'EXPIRED'`.
    *   **Database Enum:** `INIT`, `PENDING`, `PAID`, `FAILED`, `REFUNDED`, `REQUIRES_ACTION`.
    *   **Impact:** The background job for checking expired payments will fail with an "invalid input value for enum" error.
    *   **Recommendation:** Add `'EXPIRED'` to the `app.payment_status` enum in the database OR update the code to use `'FAILED'`.

## Minor Issues & Observations

### 1. Booking Status Spelling
*   **Observation:** The database uses `CANCELLED` (double 'L').
*   **Code:** `src/modules/bookings/bookings.repo.js` handles `CANCELED` (single 'L') by mapping it to `CANCELLED`.
*   **Note:** `src/modules/bookings/bookingPayment.service.js` correctly uses `CANCELLED`.
*   **Recommendation:** Standardize on `CANCELLED` (double 'L') throughout the codebase to avoid confusion.

### 2. Missing Columns in Queries (Potential)
*   **`app.user_profiles`**: The code joins with `app.user_profiles` to get `display_name` and `avatar_url`. This table exists in the SQL, but ensure `display_name` and `avatar_url` columns are populated correctly.

## Recommendations

1.  **Update Database Schema:**
    Execute the following SQL to create the missing tables and update the enum:

    ```sql
    -- Add EXPIRED to payment_status enum
    ALTER TYPE app.payment_status ADD VALUE IF NOT EXISTS 'EXPIRED';

    -- Create chat_attachments table
    CREATE TABLE IF NOT EXISTS app.chat_attachments (
        id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        message_id bigint NOT NULL REFERENCES app.chat_messages(id) ON DELETE CASCADE,
        file_name text,
        mime_type text,
        url text NOT NULL,
        size_bytes bigint,
        created_at timestamp with time zone DEFAULT now()
    );

    -- Create chat_thread_invitations table
    CREATE TABLE IF NOT EXISTS app.chat_thread_invitations (
        id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        thread_id bigint NOT NULL REFERENCES app.chat_threads(id) ON DELETE CASCADE,
        inviter_id bigint NOT NULL REFERENCES app.users(id),
        invitee_id bigint NOT NULL REFERENCES app.users(id),
        status text DEFAULT 'PENDING',
        created_at timestamp with time zone DEFAULT now(),
        UNIQUE(thread_id, invitee_id)
    );
    ```

2.  **Verify Code Logic:**
    *   Update `bookingPayment.service.js` to handle the payment expiry logic correctly if you choose not to add the `EXPIRED` enum value.
