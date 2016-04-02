-- Verrouiller CB
-- PART 6 - CrashCB
-- Romain VINDERS - 2322

SELECT s.inst_id,
s.sid,
s.serial#,
p.spid,
s.username,
s.program
FROM gv$session s
JOIN gv$process p ON p.addr = s.paddr AND p.inst_id = s.inst_id
WHERE s.type != 'BACKGROUND';
--ALTER SYSTEM DISCONNECT SESSION '65,253' IMMEDIATE; --SID,SERIAL#
ALTER USER CB ACCOUNT LOCK;
