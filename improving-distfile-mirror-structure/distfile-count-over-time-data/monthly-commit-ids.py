#/usr/bin/env python
# (c) 2019 Michał Górny
# 2-clause BSD license

import datetime
import sys
import time

year = 2000
month = 8
curts = int(datetime.date(year, month, 1).strftime('%s'))

for l in sys.stdin:
    ts, commit = l.split()
    if int(ts) > curts:
        print('{:04}-{:02} {}'.format(year, month, commit))
        month += 1
        if month > 12:
            year += 1
            month = 1
        curts = int(datetime.date(year, month, 1).strftime('%s'))
