#!/bin/bash

set -x
ansible web01 -m ping -i inventory.yml