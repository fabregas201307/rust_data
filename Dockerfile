FROM rust:latest

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

# Oracle Instant Client installation
WORKDIR /opt/oracle
RUN wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-basiclite-linuxx64.zip && \
    wget https://download.oracle.com/otn_software/linux/instantclient/instantclient-sdk-linuxx64.zip && \
    unzip instantclient-basiclite-linuxx64.zip && \
    unzip instantclient-sdk-linuxx64.zip && \
    rm *.zip

# Set Oracle environment variables
ENV ORACLE_HOME=/opt/oracle/instantclient_21_1
ENV LD_LIBRARY_PATH=$ORACLE_HOME:$LD_LIBRARY_PATH
ENV PATH=$ORACLE_HOME:$PATH
ENV TNS_ADMIN=$ORACLE_HOME/network/admin

# Create project directory
WORKDIR /usr/src/app

# Create a new Rust project
RUN cargo init

# Add database crates to dependencies
RUN cargo add mysql --features "rustls"
RUN cargo add diesel --features "mysql"
RUN cargo add sqlx --features "runtime-tokio-rustls mysql"
RUN cargo add oracle

# Copy your Rust project files
COPY . .

# Build the application
RUN cargo build --release

# Run command
CMD ["./target/release/app"]