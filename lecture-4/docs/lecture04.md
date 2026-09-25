I labben ændrede jeg tickets fra at bruge product_code til product_id. 
Først tjekkede jeg den eksisterende data. Der var 3 tickets, og alle product codes var gyldige.

Jeg prøvede først at lave ændringen direkte ved at fjerne product_code og tilføje product_id som NOT NULL. 
Det fejlede, fordi de eksisterende tickets ikke havde noget product_id.

Derefter lavede jeg ændringen gradvist. Jeg tilføjede UUID til products og en nullable product_id til tickets. 
Derefter kunne både den gamle og nye måde at skrive tickets på fungere samtidig. 
Den nye reader kunne også læse begge typer.

Jeg lavede derefter backfill, så eksisterende tickets fik det rigtige product_id ud fra deres product_code. 
Første kørsel opdaterede rows, og anden kørsel gav UPDATE 0. Verification gav 0 fejl. 
Jeg testede også en forkert kombination af product_code og product_id, som verification fandt.

Efter backfill gjorde jeg product_id NOT NULL. En gammel writer uden product_id fejlede derefter som forventet.

Til sidst testede jeg at fjerne product_code. Der var ingen views eller functions der var afhængige af den. 
Efter kolonnen blev fjernet virkede både final reader og final writer stadig. 
Testen blev kørt i en transaction og rolled back bagefter.

Pointen med labben var at en schema change med eksisterende data ikke altid kan laves på én gang. 
Her blev det gjort som expand, backfill, verify, enforce og contract. 
EF Core kan generere schema changes, men kan ikke selv vide hvordan eksisterende data skal flyttes eller hvilken rækkefølge der er sikker.
