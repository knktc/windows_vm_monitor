# -*- coding: utf-8 -*-

'''
Created on 2011-11-09
author: knktc
comment: write test result into sqlite db
'''

import os
import sys
try:
    import sqlite3
except:
    import sqlite as sqlite3

def form_value_string(info_dict, column_string):
    value_string = []
    for item in column_string:
        value_string.append(info_dict[item])
    return value_string
    
def write_sqlite(db_file, table_name, column_string, value_string):
    #open sqlite3 db file
    try:
        db_conn = sqlite3.connect(db_file)
    except:
        print 'db connect error'

    #write info into the db file    
    try:
        cursor = db_conn.cursor()
        value_string = tuple(value_string)
        sql = '''insert into %s %s values %s''' % (table_name, column_string, value_string)
        print sql
        cursor.execute(sql)
        db_conn.commit()
        cursor.close()
        db_conn.close()
        return True, value_string
    except Exception, e:
        return False, str(e)

def update_sqlite(db_file, table_name, column_string, value_string):
    domain_name = value_string[0]
    column_len = len(column_string)
    value_len = len(value_string)
    update_string = ''
    if column_len != value_len:
        return False, 'length is not match!'
    else:
        for i in range(1, column_len):
            temp = '%s = \'%s\'' % (column_string[i], value_string[i])
            update_string = update_string + temp + ','
        update_string = update_string.rstrip(',')
    sql = """update %s set %s where domain_name = \'%s\'""" % (table_name, update_string, domain_name)
    #return True, 'result'
    
    #open sqlite3 db file
    try:
        db_conn = sqlite3.connect(db_file)
    except:
        print 'db connect error'

    #write info into the db file    
    try:
        cursor = db_conn.cursor()
        print sql
        cursor.execute(sql)
        db_conn.commit()
        cursor.close()
        db_conn.close()
        return True, value_string
    except Exception, e:
        return False, str(e)