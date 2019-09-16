[Unit]
Description=node_exporter
Documentation=https://prometheus.io/
After=network.target
 
[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/prometheus/node_exporter/node_exporter
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
