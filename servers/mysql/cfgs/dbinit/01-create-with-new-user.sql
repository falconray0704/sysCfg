CREATE DATABASE IF NOT EXISTS `db01` ;
CREATE USER 'db01'@'%' IDENTIFIED BY 'db01';
GRANT ALL ON `db01`.* TO 'db01'@'%';
