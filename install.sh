#!/bin/bash

sudo cp mds.service /etc/systemd/system/mds.service

sudo systemctl start mds.service
