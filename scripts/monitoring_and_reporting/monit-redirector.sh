#!/bin/bash
mpxstats -f flat -p 9930 | python3 /scripts/xrootd_influx_exporter_flat.py
