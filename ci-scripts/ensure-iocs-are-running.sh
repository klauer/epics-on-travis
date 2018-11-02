#!/bin/bash

sleep 10

caget Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true
caproto-get -vvv Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true
caget Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true
caproto-get -vvv Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true
caget Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true
caproto-get -vvv Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true
caget Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true
caproto-get -vvv Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true
caget Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true
caproto-get -vvv Py:ao1 sim:mtr1 13SIM1:image1:PluginType_RBV || /bin/true

# -- check that all IOCs have started --
until caget Py:ao1
do
  echo "Waiting for pyepics test IOC to start..."
  sleep 0.5
done

until caget sim:mtr1
do
  echo "Waiting for motorsim IOC to start..."
  sleep 0.5
done
 
until caget 13SIM1:image1:PluginType_RBV
do
  echo "Waiting for ADSim IOC to start..."
  sleep 0.5
done
