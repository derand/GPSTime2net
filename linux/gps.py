#!/usr/bin/env python
# -*- coding: utf-8 -*-

import time
import serial
import fcntl
import calendar
import datetime
import sys

def write2log(log, s):
  #log.write(time.strftime("%d.%m.%Y %H:%M:%S.%f", time.localtime(time.time()))+':\t'+s+'\n')
  log.write(datetime.datetime.now().strftime('%d.%m.%Y %H:%M:%S.%f') + ':\t' + s + '\n')
  log.flush()

def read_loop(com, check_time=False, log_file=None):
  start_tm = time.time()
  buff = ''
  c = 0
  gps_tm_str = ''
  gps_tm = 0
  gps_status = ''
  gps_cal_type = '0'
  gps_sattelites = '0'
  gps_tm_diff = 0
  while 1:
    tmp = com.read()
    #print ord(tmp[0]), tmp
    x = tmp.find('\n')
    if x == -1:
      buff += tmp
    else:
      buff += tmp[:x-1]
      check_time = False
      #print buff
      if buff.startswith('$GPRMC'):
        arr = buff.split(',')
        if len(arr) > 12:
          # $GPRMC,170038.00,V,4628.5074,N,03041.5680,E,,,031115,,,N*4F
          #gps_tm = calendar.timegm(time.strptime('%s0000 %s'%(arr[1], arr[9]), '%H%M%S.%f %d%m%y'))
          gps_tm_str = '%s0000 %s'%(arr[1], arr[9])
          gps_tm = time.mktime(datetime.datetime.strptime(gps_tm_str, '%H%M%S.%f %d%m%y').timetuple()) - time.timezone
          gps_tm_diff = time.time()-gps_tm
          gps_status = arr[2]
      elif buff.startswith('$GPGGA'):
        arr = buff.split(',')
        if len(arr) > 6:
          # $GPGGA,170004.00,4628.5074,N,03041.5680,E,0,00,0.0,,M,,M,,*5C
          gps_cal_type = arr[6]
          gps_sattelites = arr[7]
          s = '%s%s %s %s   %.3f'%(gps_status, gps_cal_type, gps_sattelites, gps_tm_str, gps_tm_diff, )
          if log_file:
            write2log(log,s)
          print '\r%s'%s,
          sys.stdout.flush()
      buff = tmp[x+1:]
      c += 1
      #if c > 100:
      #  break
    if check_time and (time.time() - start_tm) > 3:
      com.close()
      return True
    #print tmp,
    #time.sleep(0.1)
  com.close()
  return False

if __name__=='__main__':
  prms = {
    'port': '/dev/ttyUSB0',
    'baudrate': 4800,
    #'parity': serial.PARITY_ODD,
    #'stopbits': serial.STOPBITS_TWO,
    #'bytesize': serial.SEVENBITS,
    #'timeout': 1,
  }
  # configure the serial connections (the parameters differs on the device you are connecting to)
  com = serial.Serial(**prms)
  fcntl.flock(com.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)

  #com.open()
  print com.isOpen()

  fn = time.strftime("%Y_%m_%d", time.localtime(time.time()))
  log = open(fn, 'a')

  write2log(log, '')
  write2log(log, 'Starting')

  if read_loop(com, check_time=True, log_file=log):
    print 'Reconnect'
    prms['parity'] = serial.PARITY_ODD
    com = serial.Serial(**prms)
    fcntl.flock(com.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    print com.isOpen()
    read_loop(com, log_file=log)
  log.close()

