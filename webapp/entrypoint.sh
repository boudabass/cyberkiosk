#!/bin/bash
exec gunicorn -b 0.0.0.0:5000 --workers 1 --threads 2 --timeout 60 --max-requests 1000 --max-requests-jitter 100 "app:create_app()"

