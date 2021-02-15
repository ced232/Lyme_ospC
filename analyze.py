#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Feb  7 22:11:16 2021

@author: connorduncan
"""

# ----------
# Libraries
# ----------

import csv
import itertools
import math
import pandas as pd
from scipy.stats import pearsonr
import psycopg2

invasive_types = ["A", "B", "I", "K"]
other_types = ["A3","C", "C3", "D", "D3", "E", "E3", "F", "F3", "G", "H",
              "H3", "I", "I3", "J", "L", "M", "T", "U"]

invasive_pairs = tuple(itertools.combinations(invasive_types, 2))
other_pairs = tuple(itertools.combinations(other_types, 2))

# ----------
# Functions
# ----------

# DB functions:

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

# r(Ms,Md) functions:

def allRValues (window, invasive = True):
    """ compile a list of position-by-position r(Ms,Md) scores using the 
        specified window size <window>, for just invasive strains or all 
        strains """
    result_list = []
    for i in range (5, 113):
        if invasive:
            new_dict = {}
            new_dict['invasive'] = "yes"
            new_dict['window'] = window
            new_dict['position'] = i
            new_dict['r_value'] = calculateRValueAtPosition(i, window, True)
            result_list.append(new_dict)
        else:
            new_dict = {}
            new_dict['invasive'] = "no"
            new_dict['window'] = window
            new_dict['position'] = i
            new_dict['r_value'] = calculateRValueAtPosition(i, window, False)
            result_list.append(new_dict)  
    return result_list

def calculateRValueAtPosition(pos, window, invasive):
    """ calculate individual r(Ms,Md) score for specified window size <window>
        centered on the specified amino acid position <pos> """
    m_ID = []
    m_react = []
    if invasive:
        pairs = invasive_pairs
    else:
        pairs = other_pairs
        
    for pair in pairs:
        m_ID.append(sequenceIdentity(pos, window, pair))
        m_react.append(getCrossReactivity(conn, pair))
    prelim_r_value = pearsonr(m_ID, m_react)[0]
    if math.isnan(prelim_r_value):
        r_value = 0
    else:
        r_value = round(prelim_r_value, 5)
    return r_value

# Ms functions:

def sequenceIdentity(center_pos, seq_length, pair):
    """ calculate Ms (sequence identity) value for an amino acid sequence of 
        length <seqLength> centered on <centerPos> between a given pair of 
        strains <pair> """
    matches = 0
    seq_start = int(center_pos - .5*(seq_length - 1))
    seq_end = int(center_pos + .5*(seq_length + 1))
    for position in range(seq_start, seq_end):
        is_identical = checkIdentityAtPosition(conn, position, pair[0], pair[1])
        if is_identical:
            matches += 1       
    return (matches/seq_length)

def checkIdentityAtPosition(conn, position, type1, type2, silent = False):
   """ check sequence identity at a single amino acid position <position>
       between two strains <type1> and <type2>"""
   is_identical = False
   result_list = []
   with conn:
      with conn.cursor() as cur:
         try:
            sqlcmd = "SELECT pos" + str(position) + " FROM sequence WHERE ospCType IN ('" + type1 + "','" + type2 + "')"
            cur.execute(sqlcmd)
            if silent == False:
                for record in cur:
                    record_as_string = str(record)[2]
                    result_list.append(record_as_string)
                if result_list[0] == result_list[1]:
                    is_identical = True
         except Exception as e:
            if silent == False:
                print("db read error: ")
                print(e)         
   return is_identical

# Md functions:
   
def getCrossReactivity(conn, pair, silent = False):
   """ """
   cross_reactivity = 0.00
   with conn:
      with conn.cursor() as cur:
         try:
            sqlcmd = """SELECT cross_reac 
                        FROM cross_reactivity
                        WHERE type1 = '""" + pair[0] + """' 
                        AND type2 = '""" + pair[1] + """'"""
            cur.execute(sqlcmd)
            if silent == False:
                for record in cur:
                    cross_reactivity = float(record[0])
         except Exception as e:
            if silent == False:
                print("db read error: ")
                print(e) 
   return cross_reactivity

# ----------
# Main
# ----------

conn = pgconnect()

all_r_values = []

for i in [5, 7, 9]:
    all_r_values = all_r_values + allRValues(i, invasive = True)
    all_r_values = all_r_values + allRValues(i, invasive = False)

conn.close()

df = pd.DataFrame(all_r_values)  

# ----------
# Export to CSV
# ----------

df.to_csv('data/all_r_values.csv', index = False, header = True)











