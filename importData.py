#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Feb  6 16:51:27 2021

@author: connorduncan
"""

# ----------
# Libraries
# ----------

import csv
import psycopg2

# ----------
# Functions
# ----------

def pgconnect():
    try: 
        conn = psycopg2.connect(host = 'localhost',
                                database = 'postgres',
                                user = 'postgres', 
                                password = 'password')
        print('connected')
    except Exception as e:
        print("unable to connect to the database")
        print(e)
    return conn

def pgexec( conn, sqlcmd, args, msg, silent = False ):
   """ utility function to execute some SQL statement
       can take optional arguments to fill in (dictionary)
       error and transaction handling built-in """
   retval = False
   with conn:
      with conn.cursor() as cur:
         try:
            if args is None:
               cur.execute(sqlcmd)
            else:
               cur.execute(sqlcmd, args)
            if silent == False: 
                print("success: " + msg)
            retval = True
         except Exception as e:
            if silent == False: 
                print("db error: ")
                print(e)
   return retval


# ----------
# DDL
# ----------

conn = pgconnect()

#create AA sequence data table:

pgexec (conn, "DROP TABLE IF EXISTS sequence CASCADE", None, "Reset Table sequence")

sequence_schema = "CREATE TABLE IF NOT EXISTS sequence (ospCType VARCHAR(20) PRIMARY KEY"

for i in range (1,117):
    new_string = ", pos" + str(i) + " CHAR(1)"
    sequence_schema = sequence_schema + new_string
    
sequence_schema = sequence_schema + ")"

pgexec (conn, sequence_schema, None, "Create Table sequence")

#create cross-reactivity data table:

pgexec (conn, "DROP TABLE IF EXISTS cross_reactivity", None, "Reset Table cross_reactivity")

cross_reactivity_schema = """CREATE TABLE IF NOT EXISTS cross_reactivity (
                                            type1 CHAR(1), 
                                            type2 CHAR(1),
                                            cross_reac DECIMAL(3,2),
                                            PRIMARY KEY (type1, type2),
                                            FOREIGN KEY (type1) REFERENCES sequence(ospCType),
                                            FOREIGN KEY (type2) REFERENCES sequence(ospCType)
                                            )"""

pgexec (conn, cross_reactivity_schema, None, "Create Table cross_reactivity")


# ----------
# DML
# ----------

#populate AA sequence table:

sequence_data = list(csv.DictReader(open('sequence_data.csv')))

header_string = 'ospCType'
for i in range (1,117):
    new_string = ",pos" + str(i)
    header_string = header_string + new_string
    
value_string = "%(ospCType)s"
for i in range (1,117):
    new_string = ", %(pos" + str(i) + ")s"
    value_string = value_string + new_string   
    
insert_stmt = "INSERT INTO sequence(" + header_string + ") VALUES (" + value_string + ")"

for row in sequence_data:
    pgexec (conn, insert_stmt, row, "row inserted")

#populate cross-reactivity table:
    
cross_reactivity_data = list(csv.DictReader(open('cross_reactivity_data.csv')))

insert_stmt = "INSERT INTO cross_reactivity (type1, type2, cross_reac) VALUES (%(type1)s, %(type2)s, %(cross_reac)s)"

for row in cross_reactivity_data:
    pgexec (conn, insert_stmt, row, "row inserted")

conn.close()