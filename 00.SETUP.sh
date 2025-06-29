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
# Need to install iris.config in forte/conf
#
#
cp conf/iris.config forte/conf/iris.config

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

python3 -m venv ve.oncokb
. ve.oncokb/bin/activate
pip install --upgrade pip
cd oncokb-annotator/
pip install -r requirements/common.txt -r requirements/pip3.txt
cd ..
deactivate

