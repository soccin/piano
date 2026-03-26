#
# Piano SETUP
#

#
# First install nextflow
#

cd bin
curl -s https://get.nextflow.io | bash
cd ..

#
# Get off the master branch
#

DS=$(date +%y%m%d)
git switch -c local/$DS

#
# Need to install eos.config in forte/conf
# and update nextflow.config to use it
#

cp conf/eos.config forte/conf/eos.config
cd forte
git apply ../patches/01-forte-3071d5b-250807
git add .
git commit -m "applied patch 01-forte-3071d5b-250807"
cd ..
git commit -m "module: applied patch 01-forte-3071d5b-250807" forte

# No longer cloning
# Pulling in a specific release and tracking
# it inside our repo
#
# git clone https://github.com/oncokb/oncokb-annotator.git
#

wget https://github.com/oncokb/oncokb-annotator/archive/refs/tags/v3.4.1.tar.gz
tar xvfz v3.4.1.tar.gz
mv oncokb-annotator-3.4.1 oncokb-annotator
rm v3.4.1.tar.gz

#
# user/no-user
# Venv's need no-user (ie local to venv)
# user --no-user or do
# ```
# echo "[install] > ve.oncokb/pip.conf
# user = false" >> ve.oncokb/pip.conf
# ```
#

python3 -m venv ve.oncokb
. ve.oncokb/bin/activate
pip install --no-user --upgrade pip
cd oncokb-annotator/
pip install --no-user -r requirements/common.txt -r requirements/pip3.txt
cd ..
deactivate

