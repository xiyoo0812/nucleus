
pkill -9 openresty
pkill -9 sockproc

./sockproc /tmp/shell.sock
openresty -p runtime
