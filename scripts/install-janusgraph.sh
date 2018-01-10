#!/usr/bin/env bash

if [ -d /opt/janusgraph ]
then
    echo "JanusGraph already installed."
    exit 0
fi

HOST=$1

cd /tmp/
wget "https://github.com/JanusGraph/janusgraph/releases/download/v0.2.0/janusgraph-0.2.0-hadoop2.zip"
sudo unzip janusgraph-0.2.0-hadoop2.zip -d /opt
sudo mv /opt/janusgraph-0.2.0-hadoop2 /opt/janusgraph
mkdir /opt/janusgraph/run
sudo chown -R vagrant /opt/janusgraph

echo '
network.host: 0.0.0.0
http.port: 9500
transport.tcp.port: 9600
' >> /opt/janusgraph/elasticsearch/config/elasticsearch.yml 

# Add graph connection settings
cat > /opt/janusgraph/conf/st.properties <<EOF
# JanusGraph configuration: Cassandra & Elasticsearch over sockets
storage.backend=cassandrathrift
storage.hostname=$HOST

cache.db-cache = true
cache.db-cache-clean-wait = 20
cache.db-cache-time = 180000
cache.db-cache-size = 0.25

index.search.backend=elasticsearch
index.search.hostname=127.0.0.1:9500
EOF

# Add gremlin graph connection settings
cat > /opt/janusgraph/conf/gremlin-server/st.properties <<EOF
# JanusGraph configuration: Cassandra & Elasticsearch over sockets

gremlin.graph=org.janusgraph.core.JanusGraphFactory

storage.backend=cassandrathrift
storage.hostname=$HOST

cache.db-cache = true
cache.db-cache-clean-wait = 20
cache.db-cache-time = 180000
cache.db-cache-size = 0.25

index.search.backend=elasticsearch
index.search.hostname=127.0.0.1:9500
index.search.elasticsearch.client-only=true
EOF

# Set gremlin graph configuration
sed -i '/graphs/a\  st: conf/gremlin-server/st.properties,' /opt/janusgraph/conf/gremlin-server/gremlin-server.yaml

# Set cassandra host
sed -i "/rpc_address:/c\rpc_address: $HOST" /opt/janusgraph/conf/cassandra/cassandra.yaml

cat > /etc/systemd/system/janusgraph-cassandra.service <<EOF
[Unit]
Description=JanusGraph Cassandra backend
After=network.target
PartOf=janusgraph.target

[Service]
Type=forking
PIDFile=/opt/janusgraph/run/cassandra.pid
User=vagrant
Group=vagrant
Environment=CASSANDRA_INCLUDE=/opt/janusgraph/bin/cassandra.in.sh
ExecStart=/opt/janusgraph/bin/cassandra -p /opt/janusgraph/run/cassandra.pid
StandardOutput=journal
StandardError=journal
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/janusgraph-es.service <<EOF
[Unit]
Description=JanusGraph ElasticSearch
After=network.target
PartOf=janusgraph.target

[Service]
Type=simple
User=vagrant
Group=vagrant
Environment=LOG_DIR=/opt/janusgraph/log/
WorkingDirectory=/opt/janusgraph
ExecStartPre=/opt/janusgraph/elasticsearch/bin/elasticsearch-systemd-pre-exec
ExecStart=/opt/janusgraph/elasticsearch/bin/elasticsearch --quiet -Edefault.path.logs=\${LOG_DIR}
StandardOutput=journal
StandardError=journal
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/janusgraph-gremlin.service <<EOF
[Unit]
Description=JanusGraph Gremlin server
After=network.target
PartOf=janusgraph.target

[Service]
Type=simple
User=vagrant
Group=vagrant
ExecStart=/opt/janusgraph/bin/gremlin-server.sh /opt/janusgraph/conf/gremlin-server/gremlin-server.yaml
StandardOutput=journal
StandardError=journal
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/janusgraph.target <<EOF
[Unit]
Description=JanusGraph
After=network.target
Requires=janusgraph-cassandra.service \
		janusgraph-es.service \
		janusgraph-gremlin.service
EOF
