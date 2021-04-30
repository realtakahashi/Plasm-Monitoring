echo "#Install Prometheus..."
echo "#download files..."
wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz

echo "#extract..."
tar xvf prometheus-*.tar.gz

echo "#move the files to /usr/lib/bin..."
sudo cp ./prometheus-2.26.0.linux-amd64/prometheus /usr/local/bin/
sudo cp ./prometheus-2.26.0.linux-amd64/promtool /usr/local/bin/
sudo cp -r ./prometheus-2.26.0.linux-amd64/consoles /etc/prometheus
sudo cp -r ./prometheus-2.26.0.linux-amd64/console_libraries /etc/prometheus

echo "#create dedicated users..."
sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus

echo "#create directories..."
sudo mkdir /var/lib/prometheus

echo "#change the ownership..."
sudo chown prometheus:prometheus /etc/prometheus/ -R
sudo chown prometheus:prometheus /var/lib/prometheus/ -R
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool

echo "#cleanup..."
rm -rf ./prometheus*
echo "#Prometheus was installed."

echo "#Install Node_exporter..."
echo "#download files..."
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz

echo "#extract..."
tar xvf node_exporter-*.tar.gz

echo "#move the files to /usr/lib/bin..."
sudo cp ./node_exporter-1.1.2.linux-amd64/node_exporter /usr/local/bin/

echo "#create dedicated users..."
sudo useradd --no-create-home --shell /usr/sbin/nologin node_exporter

echo "#change the ownership..."
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

echo "#cleanup..."
rm -rf ./node_exporter*
echo "#Node_exporter was installed."

echo "#Install Process_exporter."
echo "#download files..."
wget https://github.com/ncabatoff/process-exporter/releases/download/v0.7.5/process-exporter-0.7.5.linux-amd64.tar.gz

echo "#extract..."
tar xvf process-exporter-*.tar.gz

echo "#move the files to /usr/lib/bin..."
sudo cp ./process-exporter-0.7.5.linux-amd64/process-exporter /usr/local/bin/

echo "#create dedicated users..."
sudo useradd --no-create-home --shell /usr/sbin/nologin process-exporter

echo "#create directories..."
sudo mkdir /etc/process-exporter

echo "#change the ownership..."
sudo chown process-exporter:process-exporter /etc/process-exporter -R
sudo chown process-exporter:process-exporter /usr/local/bin/process-exporter

echo "#cleanup..."
rm -rf ./process-exporter*
echo "#Process_exporter was installed."

echo "#Install AlertManager."
echo "#download files..."
wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz

echo "#extract..."
tar xvf alertmanager-*.tar.gz

echo "#move the files to /usr/lib/bin..."
sudo cp ./alertmanager-0.21.0.linux-amd64/alertmanager /usr/local/bin/
sudo cp ./alertmanager-0.21.0.linux-amd64/amtool /usr/local/bin/

echo "#create dedicated users..."
sudo useradd --no-create-home --shell /usr/sbin/nologin alertmanager

echo "#create directories..."
sudo mkdir /etc/alertmanager
sudo mkdir /var/lib/alertmanager

echo "#change the ownership..."
sudo chown alertmanager:alertmanager /etc/alertmanager/ -R
sudo chown alertmanager:alertmanager /var/lib/alertmanager/ -R
sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
sudo chown alertmanager:alertmanager /usr/local/bin/amtool

echo "#cleanup..."
rm -rf ./alertmanager*
echo "#AlertManager was installed."

echo "#Install grafana."
echo "#download files..."
wget https://dl.grafana.com/oss/release/grafana_7.5.3_amd64.deb

echo "#extract..."
sudo dpkg -i grafana*.deb
sudo grafana-cli plugins install camptocamp-prometheus-alertmanager-datasource
sudo systemctl restart grafana-server

echo "#cleanup..."
rm -rf ./grafana*
echo "#Grafana was installed."

echo "#####"

echo "#copy configurations."
cp -p ./prometheus.yml /etc/prometheus/prometheus.yml
cp -p ./rules.yml /etc/prometheus/rules.yml
cp -p ./onfig.yml /etc/process-exporter/config.yml
cp -p ./alertmanager.yml /etc/alertmanager/alertmanager.yml

echo "#check files..."
promtool check rules /etc/prometheus/rules.yml
promtool check config /etc/prometheus/prometheus.yml

echo "#copy service files."
cp -p ./prometheus.service /etc/systemd/system/prometheus.service
cp -p ./node_exporter.service /etc/systemd/system/node_exporter.service
cp -p ./process-exporter.service /etc/systemd/system/process-exporter.service
cp -p ./alertmanager.service /etc/systemd/system/alertmanager.service

echo "#Launch and Active Services"
systemctl daemon-reload
sudo systemctl start prometheus.service
sudo systemctl start node_exporter.service
sudo systemctl start process-exporter.service
sudo systemctl start alertmanager.service
sudo systemctl start grafana-server

systemctl status prometheus.service
systemctl status node_exporter.service
systemctl status process-exporter.service
systemctl status alertmanager.service
systemctl status grafana-server

sudo systemctl enable prometheus.service
sudo systemctl enable node_exporter.service
sudo systemctl enable process-exporter.service
sudo systemctl enable alertmanager.service
sudo systemctl enable grafana-server

echo "#Test Alert manager"
curl -H "Content-Type: application/json" -d '[{"labels":{"alertname":"Test"}}]' localhost:9093/api/v1/alerts

echo "#Finished"
