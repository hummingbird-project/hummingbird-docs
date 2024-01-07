> psql postgres
psql (14.10 (Homebrew))
Type "help" for help.

postgres=# create database hummingbird;
CREATE DATABASE
postgres=# \c hummingbird
You are now connected to database "hummingbird" as user "user".
hummingbird=# create role todos createrole login password 'todos';
CREATE ROLE
hummingbird=# \q
