CREATE TABLE experiment (
       id               INTEGER PRIMARY KEY AUTOINCREMENT,
       name             TEXT    NOT NULL,
       plan             TEXT,
       created_at       TIMESTAMP,
       updated_at       TIMESTAMP
);

CREATE TABLE variant (
       id               INTEGER PRIMARY KEY AUTOINCREMENT,
       weight           INTEGER  NOT NULL,
       payload          TEXT    NOT NULL,
       experiment_id    INTEGER NOT NULL,
       created_at       TIMESTAMP,
       updated_at       TIMESTAMP,

       FOREIGN KEY (experiment_id) REFERENCES experiment(id)
);

CREATE TABLE subject (
      id                INTEGER PRIMARY KEY AUTOINCREMENT,
      device_id         TEXT    NOT NULL,
      variant_id        INTEGER,
      created_at        TIMESTAMP,
      updated_at        TIMESTAMP,

      FOREIGN KEY (variant_id) REFERENCES variant(id)
);

CREATE INDEX device_id_idx ON subject(device_id);
