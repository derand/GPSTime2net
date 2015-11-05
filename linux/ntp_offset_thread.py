#!/usr/bin/env python
# -*- coding: utf-8 -*-

__author__ = 'Andrey Derevyagin'
__copyright__ = 'Copyright © 2015'

import threading
import ntplib
import time

class NTPOffsetThread(threading.Thread):
    def __init__(self, com_reader_thread, log_queue=None):
        threading.Thread.__init__(self)
        self.setDaemon(True)
        self.com_reader_thread = com_reader_thread
        self.logger_queue = log_queue
        self._running = False

    def run(self):
        self._running = True
        while True:
            if not self._running:
                break
            c = ntplib.NTPClient()
            response = c.request('europe.pool.ntp.org', version=3)
            self.com_reader_thread.ntp_offset = response.offset
            time.sleep(10)


    def stop(self):
        self._running = False