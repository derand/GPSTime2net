#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'Andrey Derevyagin'
__copyright__ = 'Copyright © 2015'

import threading, Queue
import time, datetime


class Message:
    def __init__(self, msg, flush=True):
        self.timestamp = datetime.datetime.now()
        self.msg = msg
        self.flush = flush


class LoggerThread(threading.Thread):
    def __init__(self, log_queue=None):
        threading.Thread.__init__(self)
        self.setDaemon(True)
        #self.com_prms = com_prms
        self.logger_queue = log_queue
        fn = time.strftime("%Y_%m_%d", time.localtime(time.time())) + '.log'
        self.log = open(fn, 'a')
        self._running = False

    def run(self):
        self._running = True
        while True:
            if not self._running:
                break
            try:
                msg = self.logger_queue.get(block=True, timeout=1)
            except Queue.Empty, e:
                msg = None
            if msg:
                self.log.write(msg.timestamp.strftime('%d.%m.%Y %H:%M:%S.%f') + ':\t' + msg.msg + '\n')
                if msg.flush:
                    self.log.flush()
        self.log.close()

    def stop(self):
        self._running = False
