DROP DATABASE zero;
CREATE DATABASE zero;
\c zero

CREATE TABLE subjects (
  subject_name TEXT NOT NULL
);
ALTER TABLE subjects ADD CONSTRAINT pk__t_subjects
  PRIMARY KEY (subject_name)
;

CREATE TABLE account_types (
  account_type TEXT NOT NULL
);
ALTER TABLE account_types ADD CONSTRAINT pk__t_account_types
  PRIMARY KEY (account_type)
;
INSERT INTO account_types(account_type) VALUES
  ('checking'),
  ('saving'),
  ('credit_card')
;

CREATE TABLE accounts (
  account_name    TEXT    NOT NULL,
  account_type    TEXT    NOT NULL,
  initial_balance NUMERIC NOT NULL
);
ALTER TABLE accounts ADD CONSTRAINT pk__t_accounts
  PRIMARY KEY (account_name)
;
ALTER TABLE accounts ADD CONSTRAINT fk__t_accounts__c_account_type
  FOREIGN KEY              (account_type)
  REFERENCES  account_types(account_type)
  ON UPDATE CASCADE
  ON DELETE RESTRICT
;
INSERT INTO accounts(account_name, account_type, initial_balance) VALUES
  ('CK Capital One', 'checking', 0),
  ('CC Discover', 'credit_card', 100)
;

--CREATE TABLE accounts_currently (
--  account_name TEXT    NOT NULL,
--  balance      NUMERIC NOT NULL
--);
--ALTER TABLE accounts_currently ADD CONSTRAINT pk__t_accounts_currently
--  PRIMARY KEY (account_name)
--;
--ALTER TABLE accounts_currently ADD CONSTRAINT fk__t_accounts_currently__c_account_name
--  FOREIGN KEY         (account_name)
--  REFERENCES  accounts(account_name)
--  ON UPDATE CASCADE
--  ON DELETE CASCADE
--;

CREATE TABLE transactions (
  transaction_id        SERIAL      NOT NULL,
  at                    TIMESTAMPTZ NOT NULL,
  account_name          TEXT        NOT NULL,
  subject_name          TEXT        NOT NULL,
  amount                NUMERIC     NOT NULL,
  memo                  TEXT        NOT NULL DEFAULT ''
);
ALTER TABLE transactions ADD CONSTRAINT pk__t_transactions
  PRIMARY KEY (transaction_id)
;
ALTER TABLE transactions ADD CONSTRAINT fk__t_transactions__c_account_name
  FOREIGN KEY         (account_name)
  REFERENCES  accounts(account_name)
  ON UPDATE CASCADE
  ON DELETE RESTRICT
;
ALTER TABLE transactions ADD CONSTRAINT fk__t_transactions__c_subject_name
  FOREIGN KEY         (subject_name)
  REFERENCES  subjects(subject_name)
  ON UPDATE CASCADE
  ON DELETE RESTRICT
;

CREATE TABLE intervals (
  interval_type TEXT
);
ALTER TABLE intervals ADD CONSTRAINT pk__t_intervals
  PRIMARY KEY (interval_type)
;
INSERT INTO intervals(interval_type) VALUES
  ('daily'),
  ('weekly'),
  ('monthly'),
  ('yearly')
;

CREATE TABLE recurring_transactions (
  recurring_transaction_id SERIAL      NOT NULL
  at                       TIMESTAMPTZ NOT NULL
  interval_type            TEXT        NOT NULL,
  interval_count           INTEGER     NOT NULL,
  account_name             TEXT            NULL,
  subject_name             TEXT            NULL,
  amount                   NUMERIC         NULL,
  memo                     TEXT        NOT NULL DEFAULT ''
);
ALTER TABLE recurring_transactions ADD CONSTRAINT pk__t_recurring_transactions
  PRIMARY KEY (recurring_transaction_id)
;
ALTER TABLE recurring_transactions ADD CONSTRAINT fk__t_recurring_transactions__c_account_name
  FOREIGN KEY         (account_name)
  REFERENCES  accounts(account_name)
  ON UPDATE CASCADE
  ON DELETE RESTRICT
;
ALTER TABLE recurring_transactions ADD CONSTRAINT fk__t_recurring_transactions__c_subject_name
  FOREIGN KEY         (subject_name)
  REFERENCES  subjects(subject_name)
  ON UPDATE CASCADE
  ON DELETE RESTRICT
;
