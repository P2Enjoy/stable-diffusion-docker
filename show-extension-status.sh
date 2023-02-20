#while (true); do 
sudo chmod -R g+rw *; sudo chown -R root:martino *; 
find $PWD/data/config/auto/extensions -mindepth 1 -maxdepth 1 -type d | xargs -i^ bash -c 'cd $0; echo "$0:"; git fetch --all; git status; git config --get remote.origin.url' ^
sleep 30;
#done
