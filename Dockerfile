FROM resin/raspberry-pi-golang:1.10

RUN [ "cross-build-start" ]

ENV OPENCV_VERSION=3.4.2 \
    TMP_DIR=/tmp/

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install unzip build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev libjpeg-dev libpng-dev libtiff-dev libdc1394-22-dev

RUN go get -u -d gocv.io/x/gocv
WORKDIR /go/src/gocv.io/x/gocv
RUN make download &>/dev/null

# RUN make build
WORKDIR ${TMP_DIR}opencv/opencv-${OPENCV_VERSION}/build
RUN cmake \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D OPENCV_EXTRA_MODULES_PATH=${TMP_DIR}opencv/opencv_contrib-${OPENCV_VERSION}/modules \
        -D BUILD_DOCS=OFF BUILD_EXAMPLES=OFF \
        -D BUILD_TESTS=OFF \
        -D BUILD_PERF_TESTS=OFF \
        -D BUILD_opencv_java=OFF \
        -D BUILD_opencv_python=OFF \
        -D BUILD_opencv_python2=OFF \
        -D BUILD_opencv_python3=OFF \
        -D WITH_OPENCL=ON \
        -D WITH_JASPER=OFF ..
RUN make -j 4 -s
RUN make preinstall
WORKDIR /go/src/gocv.io/x/gocv

RUN make sudo_install
RUN make clean

#RUN apt-get purge build-essential cmake
RUN apt-get autoremove
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

#RUN make verify
RUN go install gocv.io/x/gocv
RUN go build gocv.io/x/gocv

RUN go get github.com/hybridgroup/mjpeg
RUN go build github.com/hybridgroup/mjpeg

ADD model /models

RUN [ "cross-build-end" ]

CMD ["echo", "'No CMD command was set in Dockerfile!" ]
