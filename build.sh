git clone https://github.com/influxdata/influxdb.git
cd influxdb
git checkout v2.1.1
cp ../Dockerfile .
docker build -t matrinos/influxdb:v2.1.1-p1 .