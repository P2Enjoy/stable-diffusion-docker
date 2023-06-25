#while (true); do 
sudo chmod -R g+rw *; sudo chown -R root:martino *; 
sudo find . -regex '^.*\(__pycache__\|\.py[co]\)$' -delete;
find $PWD/data/config/auto/extensions -mindepth 1 -maxdepth 1 -type d | xargs -i^ bash -c 'cd $0; echo "$0:"; git config pull.rebase true; git pull;' ^
sleep 30;
#done
