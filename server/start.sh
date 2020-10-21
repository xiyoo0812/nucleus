
pkill -9 openresty
rm -fr runtime
mkdir runtime
mkdir runtime/logs
mkdir runtime/images
mkdir runtime/sshkeys
mkdir runtime/playbooks

cp -r conf  runtime/conf
cp -r script  runtime/script
cp -r extend  runtime/extend
cp -r resource  runtime/resource

export ANSIBLE_HOST_KEY_CHECKING=False
openresty -p runtime
