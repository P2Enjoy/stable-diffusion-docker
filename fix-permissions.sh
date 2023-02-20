#while (true); do 
sudo chmod -R ug+rw *; sudo chown -R  ${UID:-0}:${GID:-0} *; 
find $PWD/data/config/auto/extensions -mindepth 1 -maxdepth 1 -type d | xargs -i^ bash -c 'git config --global --add safe.directory $0;' ^
sleep 30;
#done
