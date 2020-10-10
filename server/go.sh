
pkill -9 openresty
pkill -9 sockproc

rm -fr runtime
mkdir runtime
mkdir runtime/logs
rm -fr /tmp/shell.sock

cp -r conf  runtime/conf
cp -r script  runtime/script
cp -r extend  runtime/extend
cp -r resource  runtime/resource

./extend/sockproc/sockproc /tmp/shell.sock
openresty -p runtime
