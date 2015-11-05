#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'Andrey Derevyagin'
__copyright__ = 'Copyright © 2015'

import threading#, Queue
import serial
import fcntl
import time, datetime
import sys

from logger_thread import Message

class ComReadThread(threading.Thread):
    def __init__(self, com_prms, log_queue=None):
        threading.Thread.__init__(self)
        self.setDaemon(True)
        self.com_prms = com_prms
        self.logger_queue = log_queue
        self.com = None
        self.ntp_offset = 0
        self.ntp_offset_prev = self.ntp_offset

    def run(self):
        # configure the serial connections (the parameters differs on the device you are connecting to)
        self.com = serial.Serial(**self.com_prms)
        fcntl.flock(self.com.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)

        #self.com.open()
        print self.com.isOpen()

        if self.read_loop(check_time=True):
            print 'Reconnect'
            self.com_prms['parity'] = serial.PARITY_ODD
            self.com = serial.Serial(**self.com_prms)
            fcntl.flock(self.com.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            print self.com.isOpen()
            self.read_loop()
        #log.close()

    def read_loop(self, check_time=False):
        start_tm = time.time()
        buff = ''
        c = 0
        gps_tm_str = ''
        gps_tm = 0
        gps_status = ''
        gps_cal_type = '0'
        gps_sattelites = '0'
        gps_tm_diff = 0
        gps_gsv_sattelites = 0
        gps_gsv_sattelites_count = 0
        gps_gsv_sattelites_power = []
        max_length = 0
        while 1:
            tmp = self.com.readline(80)
            #print ord(tmp[0]), len(tmp), tmp
            x = tmp.find('\n')
            if x == -1:
                buff += tmp
            else:
                buff += tmp[:x-1]
                check_time = False
                #print buff
                if len(buff) and buff[0] == '$':
                    arr = buff.split(',')
                    if arr[0] == '$GPRMC':
                        if len(arr) > 12:
                            # $GPRMC,170038.00,V,4628.5074,N,03041.5680,E,,,031115,,,N*4F
                            gps_tm_str = '%s0000 %s'%(arr[1], arr[9])
                            #gps_tm = calendar.timegm(time.strptime(gps_tm_str, '%H%M%S.%f %d%m%y'))   # '.%f' not supported
                            gps_tm = time.mktime(datetime.datetime.strptime(gps_tm_str, '%H%M%S.%f %d%m%y').timetuple()) - time.timezone
                            gps_tm_diff = time.time()-gps_tm
                            gps_status = arr[2]
                    elif arr[0] == '$GPGGA':
                        if len(arr) > 7:
                            # $GPGGA,170004.00,4628.5074,N,03041.5680,E,0,00,0.0,,M,,M,,*5C
                            gps_cal_type = arr[6]
                            gps_sattelites = arr[7]
                    elif arr[0] == '$GPGSV':
                        if arr[2] == '1':
                            gps_gsv_sattelites = 0
                            gps_gsv_sattelites_power = []
                        gps_gsv_sattelites_count = arr[3]
                        idx = 7
                        while idx < len(arr):
                            power = arr[idx].split('*')[0]
                            if len(power) > 0:
                                gps_gsv_sattelites += 1
                                gps_gsv_sattelites_power.append(power)
                            idx += 4

                    if arr[0] == '$GPGSV' and arr[1] == arr[2]:
                        c += 1
                        s = '\'%s\' %s%s %s(%02d/%s %s)  %.6f'%(gps_tm_str, gps_status, gps_cal_type, gps_sattelites, gps_gsv_sattelites, gps_gsv_sattelites_count, '-'.join(gps_gsv_sattelites_power), gps_tm_diff, )
                        if self.ntp_offset == self.ntp_offset_prev:
                            self.logger_queue.put(Message(s, (c%10) == 0))
                            s += '  %.6f'%self.ntp_offset
                        else:
                            s += '  %.6f'%self.ntp_offset
                            self.logger_queue.put(Message(s, (c%10) == 0))
                        max_length = max(max_length, len(s))
                        print '\r%s'%s.ljust(max_length),
                        sys.stdout.flush()
                        self.ntp_offset_prev = self.ntp_offset
                buff = tmp[x+1:]
            if check_time and (time.time() - start_tm) > 3:
                self.com.close()
                return True
        self.com.close()
        return False
