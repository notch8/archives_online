# Grant privileges to the application user.
GRANT ALL PRIVILEGES ON `archives_online_test`.* TO 'archives-online'@'%';
GRANT CREATE ON *.* TO 'archives-online'@'%';
FLUSH PRIVILEGES; 