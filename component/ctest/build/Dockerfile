FROM docker.io/phusion/baseimage:0.9.21
MAINTAINER dian.li <lidian@huawei.com>
RUN apt-get update && apt-get install -y tar git golang
WORKDIR /var/opt/gopath/src/github.com/Huawei/
ENV GOPATH /var/opt/gopath
ENV PATH $PATH:$GOROOT/bin:$GOPATH:/bin
RUN git clone https://github.com/Huawei/containerops.git
WORKDIR containerops/component/ctest/build
RUN go get
ADD main.go main.go
ADD module module
COPY component-auto-ci.sh component-auto-ci.sh
CMD ./component-auto-ci.sh


