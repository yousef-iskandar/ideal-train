# Server Storage
This folder contains scripts and modules that are present ONLY on the server, But are not executed on startup.

## Sensitive data is OK here
Files in this directory should be considered PRIVATE as only the server will have access to them.
Clients are unable to see, modify, or extract any code placed in this directory.
Use this folder to write code that ***must not*** be tampered with by clients.