#!/usr/bin/env python
# -*- coding: utf-8 -*-

#import time
#import serial
#import fcntl
#import calendar
#import datetime
#import sys

import threading, Queue
from logger_thread import Message, LoggerThread
from com_read_thread import ComReadThread
import time
from ntp_offset_thread import NTPOffsetThread

if __name__=='__main__':
    log_queue = Queue.Queue()
    log_queue.put(Message(''))
    log_queue.put(Message('Starting multithreading'))

    logger = LoggerThread(log_queue)
    logger.start()

    prms = {
        'port': '/dev/ttyUSB0',
        'baudrate': 4800,
        #'parity': serial.PARITY_ODD,
        #'stopbits': serial.STOPBITS_TWO,
        #'bytesize': serial.SEVENBITS,
        #'timeout': 1,
    }
    #com_reader = ComReadThread(prms, log_queue)
    #com_reader.start()
    com_reader = None

    ntp_offset_thread = NTPOffsetThread(com_reader_thread=com_reader, log_queue=log_queue)
    ntp_offset_thread.start()

    while True:
        try:
            time.sleep(1)
        except KeyboardInterrupt:
            break

    ntp_offset_thread.stop()
    if com_reader:
        com_reader.stop()
    logger.stop()

    ntp_offset_thread.join()
    if com_reader:
        com_reader.join()
    logger.join()
