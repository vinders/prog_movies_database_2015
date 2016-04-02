#########################################################################

    Movie database SQL management
    -----------------------------------------------------------------
    
    Author      : Romain Vinders
    Languages   : Oracle SQL, PL-SQL, Java
    Date        : 2015
    License     : GPLv2

#########################################################################

Database management project (Oracle SQL) with Java GUI

- PL-SQL stored procedures, job scheduling, triggers
- Java access bean, dialogs, procedure calls
- create main database and linked backup database
- IO management procedures
- backup triggers and scheduled job
- restoration procedure and scheduled job
- import data from huge text file (not in the repository, because of its size (182 Mo))
- analyse imported file, stats, retrieve data (splits, regex, ...)
- data search with search filters (title, actor(s), director(s), ...)
- database crash simulation -> use backup database instead
- as soon as the main database is ok, use it again (and restore data if necessary)
