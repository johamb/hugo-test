---
title: "Postgres Scripts"
date: 2022-05-10T10:30:18+02:00
draft: true
---

## Create new database and user
```
CREATE DATABASE {DB};
CREATE USER {USER} WITH ENCRYPTED PASSWORD '{PW}';
GRANT ALL PRIVILEGES ON DATABASE {DB} TO {USER};
```