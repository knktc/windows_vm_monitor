#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
created on: 2012-02-07
author: knktc
comment: a script to define a socket connect server
'''

import os
import sys
import socket
import ConfigParser
import write_sqlite
import datetime

current_path = os.path.dirname(os.path.abspath(sys.argv[0]))

status_dict = {'first_run':'null', 'domain_name':'null', 'domain_ip':'null', 'program_info':'null', 'disk_usage':'null', 'mem_usage':'null'}
column_string = ('domain_name', 'domain_ip', 'last_hostalive', 'program_info', 'disk_usage', 'mem_usage')


def form_status_string(info_dict):
    status_string = []
    current_time = (datetime.datetime.now()).isoformat(' ')
    #get host name
    domain_name = info_dict['domain_name']
    #get host ip
    domain_ip = info_dict['domain_ip']
    #get last host alive time
    last_hostalive = current_time
    #get last program alive time
    program_info = info_dict['program_info']
    print program_info
    #get disk usage
    disk_usage = info_dict['disk_usage']
    
    #get memory usage
    mem_usage = info_dict['mem_usage']
    
    status_string = [domain_name, domain_ip, last_hostalive, program_info, disk_usage, mem_usage]
    return status_string

def check_first_run(info_dict):
    first_run = info_dict['first_run']
    if first_run == 1:
        return True
    else:
        return False

if __name__ == '__main__':
    #get config
    config_file = ConfigParser.ConfigParser()
    config_file_path = os.path.join(current_path, r'config.ini')
    config_file.read(config_file_path)
    
    #read config from config file
    server_ip = config_file.get('server', 'server_ip')
    server_port = config_file.get('server', 'server_port')
    max_conn = config_file.get('server', 'max_conn')
    conn_timeout = config_file.get('server', 'conn_timeout')
    buffer_size = config_file.get('server', 'buffer_size')
    db_file_name = config_file.get('server', 'db_file')
    table_name = config_file.get('server', 'table_name')
    
    db_file = os.path.join(current_path, db_file_name)
    #create socket info recive server
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  
    sock.bind((server_ip, int(server_port)))  
    sock.listen(int(max_conn))
    while True:  
        connection, address = sock.accept()  
        try:  
            connection.settimeout(int(conn_timeout))  
            buf = connection.recv(int(buffer_size))
            print buf
            try:
                recv_status_dict = eval(str(buf))
                status_string = form_status_string(recv_status_dict)
                print status_string[0]
            except Exception, e:
                status_string = 'null'
                print str(e)
            
            if status_string == 'null':
                pass
            elif check_first_run(recv_status_dict):
                write_db_result = write_sqlite.write_sqlite(db_file, table_name, column_string, status_string)
                if write_db_result[0]:
                    pass
                else:
                    print 'write db error'
                    print write_db_result[1]
            else:
                update_db_result = write_sqlite.update_sqlite(db_file, table_name, column_string, status_string)          
                if update_db_result[0]:
                    pass
                else:
                    print 'update db error'
                    print update_db_result[1]
            
            #get buffer content and operate the kvm
        except socket.timeout:  
            print 'time out'
        except KeyboardInterrupt:
            connection.close()
            break
        connection.close()  
