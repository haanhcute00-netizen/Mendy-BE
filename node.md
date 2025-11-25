

mail :  wehealing.listening@gmail.com
pass :  wehealing123





[ Client (Web/Mobile) ]
        |
        | HTTP (REST) + WebSocket (Realtime)
        v
+------------------+
|  Express Server  |
|   (app.js)       |
+------------------+
   |       |
   |       +----------------+
   |                        |
[Routes]                [Sockets]
   |                        |
   |                        |
   v                        v
+------------+       +-----------------+
| Controllers|       | Socket Handlers |
+------------+       +-----------------+
       |                      |
       v                      v
+-------------+         +-------------+
|  Services   |         |   Services  |
| (business   |         | (chat/call) |
|  logic)     |         +-------------+
+-------------+
       |
       v
+--------------+
| Repositories |
| (SQL queries)|
+--------------+
       |
       v
   [ PostgreSQL DB ]
       |
       +-- Tables: users, profiles, posts, comments,
           follows, bookings, payments, chat_threads,
           call_sessions, audit_logs ...

