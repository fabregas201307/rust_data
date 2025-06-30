FROM rust:latest

ENV no_proxy="localhost,127.0.0.1,.acml.com,.beehive.com,.azurecr.io,.azure.net,169.254.169.254,172.16.0.1,.rangulapapi.acml.com,.rapapi.acml.com,.fiqprod3.ac.lp.acml.com" \
    http_proxy="http://gmdvproxy.acml.com:8080" \
    https_proxy="http://gmdvproxy.acml.com:8080"

ARG AZ_TENANT=""
ENV AZ_TENANT $AZ_TENANT

ARG AZ_CLIENT=""
ENV AZ_CLIENT $AZ_CLIENT

ARG AZ_SECRET=""
ENV AZ_SECRET $AZ_SECRET

ENV DEBIAN_FRONTEND=noninteractive
ENV PTP_DEFAULT_TIMEOUT 208

ARG PAT=""
ENV PAT $PAT

# Copy certificates and requirement files
# # create the directory if it doesn't exist
RUN mkdir -p /etc/pki/ca-trust/source/anchors/

# # install certificate management tools and update CA certificates
RUN apt-get update && apt-get install -y \
    ca-certificates \
    openssl \
    && update-ca-certificates

# # update ca certificates
COPY AB-Certs/* /usr/local/share/ca-certificates/
RUN update-ca-certificates

# # for f in /usr/local/share/ca-certificates/*.crt ; do mv "$f" "${f}.crt" ; done &&
RUN apt-get -y --no-install-recommends install \
    ca-certificates \
    unixodbc \
    freetds-bin freetds-dev tdsodbc \
    curl \
    libpq-dev \
    && \
    rm -rf /var/lib/apt/lists/*

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    unixodbc \
    unixodbc-dev \
    curl \
    libaio1 \
    wget \
    unzip
    
# MySQL Client Library (for mysql-native and diesel)
RUN apt-get install -y default-libmysqlclient-dev

# Oracle Client Libraries
RUN mkdir -p /opt/oracle \
    && wget https://download.oracle.com/otn_software/linux/instantclient/193800/instantclient-basic-linux.x64-19.3.0.0.0dbru.zip \
    && wget https://download.oracle.com/otn_software/linux/instantclient/193800/instantclient-sdk-linux.x64-19.3.0.0.0dbru.zip \
    && unzip instantclient-basic-linux.x64-19.3.0.0.0dbru.zip -d /opt/oracle \
    && unzip instantclient-sdk-linux.x64-19.3.0.0dbru.zip -d /opt/oracle \
    && rm -f *.zip \
    && mv /opt/oracle/instantclient_19_3 /opt/oracle/instantclient

# Set Oracle environment variables
ENV ORACLE_HOME=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH="${ORACLE_HOME}:${LD_LIBRARY_PATH:-}"
ENV PATH="${ORACLE_HOME}:${PATH}"
ENV OCI_LIB_DIR="${ORACLE_HOME}"
ENV OCI_INCLUDE_DIR="${ORACLE_HOME}/sdk/include"

# Create project directory
WORKDIR /usr/src/app

# Copy your Rust project files
# This will include your Cargo.toml with the proper [package] section
COPY . .

# Build the application
RUN cargo build --release

# Run command
# Note: Changed to use the correct binary name from your Cargo.toml
CMD ["./target/release/rust_abdata"]