/*1. (2 points) Use a sequence to generate the values for log# automatically when new log records are
inserted into the logs table. Start the sequence with 1000 with an increment of 1. 
**/
drop sequence log_sequence;
create sequence log_sequence increment by 1 start with 1000;