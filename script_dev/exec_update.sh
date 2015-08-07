#!/bin/bash

sudo update_engine_client --omaha_url=http://update.crosbuilder.click:44225/update --update
sudo stateful_update
