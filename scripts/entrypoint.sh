#!/bin/bash

. /kb/deployment/user-env.sh

python ./scripts/prepare_deploy_cfg.py ./deploy.cfg ./work/config.properties
ADIR=/kb/assembly/lib/assembly
sed -i  "s|140.221.67.235:7445|$(grep endpoint deploy.cfg|sed 's/.*= *//')/shock-api|"  /kb/assembly/lib/assembly/arast.conf 

if [ $# -eq 0 ] ; then
  sh ./scripts/start_server.sh
elif [ "${1}" = "test" ] ; then
  echo "Run Tests"
  mongod --smallfiles --fork --logpath=/tmp/mongo.log --dbpath=/db
  rabbitmq-server  &
  python $ADIR/arastd.py  -c $ADIR/arast.conf --logfile /tmp/arastd.log &
  (sleep 10;python $ADIR/ar_computed.py -s localhost -d /kb/module/work/ -c $ADIR/ar_compute.conf  -b /kb/runtime/assembly/ )&
  make test
elif [ "${1}" = "async" ] ; then
  mongod --smallfiles --fork --logpath=/tmp/mongo.log --dbpath=/db
  rabbitmq-server  &
  python $ADIR/arastd.py  -c $ADIR/arast.conf --logfile /tmp/arastd.log &
  (sleep 10;python $ADIR/ar_computed.py -s localhost -d /kb/module/work/ -c $ADIR/ar_compute.conf  -b /kb/runtime/assembly/ )&
  sh ./scripts/run_async.sh
elif [ "${1}" = "init" ] ; then
  echo "Initialize module"
elif [ "${1}" = "bash" ] ; then
  bash
elif [ "${1}" = "report" ] ; then
  export KB_SDK_COMPILE_REPORT_FILE=./work/compile_report.json
  make compile
else
  echo Unknown
fi
