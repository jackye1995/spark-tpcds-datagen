#!/usr/bin/env bash

# Install Iceberg dependencies
AWS_SDK_VERSION=2.17.68
ICEBERG_VERSION=0.12.0
MAVEN_URL=https://repo1.maven.org/maven2
ICEBERG_MAVEN_URL=$MAVEN_URL/org/apache/iceberg
AWS_MAVEN_URL=$MAVEN_URL/software/amazon/awssdk
LIB_PATH=/usr/share/aws/aws-java-sdk/

AWS_PACKAGES=(
  "bundle"
  "url-connection-client"
)

ICEBERG_PACKAGES=(
  "iceberg-spark3-runtime"
)

install_maven_dependencies () {
  install_path=$1
  download_url=$2
  version=$3
  shift
  pkgs=("$@")
  for pkg in "${pkgs[@]}"; do
    sudo wget -P $install_path $download_url/$pkg/$version/$pkg-$version.jar
  done
}

install_maven_dependencies $LIB_PATH $ICEBERG_MAVEN_URL $ICEBERG_VERSION "${ICEBERG_PACKAGES[@]}"
install_maven_dependencies $LIB_PATH $AWS_MAVEN_URL $AWS_SDK_VERSION "${AWS_PACKAGES[@]}"

# Pull and build TPCDS datagen
sudo yum install git -y
sudo mkdir /etc/tpcds
git clone https://github.com/jackye1995/spark-tpcds-datagen.git /home/hadoop/spark-tpcds-datagen
cd /home/hadoop/spark-tpcds-datagen
sudo git checkout iceberg
sudo build/mvn install -DskipTests
sudo cp src/main/resources/binaries/Linux/x86_64/dsdgen /etc/tpcds/.
sudo cp src/main/resources/binaries/Linux/x86_64/tpcds.idx /etc/tpcds/.