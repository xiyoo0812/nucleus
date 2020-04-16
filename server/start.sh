
pkill -9 openresty
rm -fr runtime
mkdir runtime
mkdir runtime/logs

cp -r conf  runtime/conf
cp -r script  runtime/script
cp -r extend  runtime/extend
cp -r resource  runtime/resource

openresty -p runtime
