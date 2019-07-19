FROM arm64v8/python:2-alpine
EXPOSE 5000

ENV CURA_VERSION=15.04.6
ARG tag=master

WORKDIR /opt/octoprint

# In case of alpine
RUN apk update && apk upgrade \
    && apk add --no-cache bash git openssh libc-dev gcc musl-dev linux-headers usbip-utils-dev \
                && pip install virtualenv \
                && rm -rf /var/cache/apk/*

#install ffmpeg
RUN cd /tmp \
  && wget -O ffmpeg.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-arm64-static.tar.xz \
        && mkdir -p /opt/ffmpeg \
        && tar xvf ffmpeg.tar.xz -C /opt/ffmpeg --strip-components=1 \
  && rm -Rf /tmp/*

#install Cura
#RUN cd /tmp \
#  && wget https://github.com/Ultimaker/CuraEngine/archive/${CURA_VERSION}.tar.gz \
#  && tar -zxf ${CURA_VERSION}.tar.gz \
# && cd CuraEngine-${CURA_VERSION} \
# && mkdir build \
# && make \
# && mv -f ./build /opt/cura/ \
# && rm -Rf /tmp/*

#Create an octoprint user
RUN adduser -D -h /home/octoprint -s /bin/bash octoprint && adduser octoprint dialout
RUN chown octoprint:octoprint /opt/octoprint
USER octoprint
#This fixes issues with the volume command setting wrong permissions
RUN mkdir /home/octoprint/.octoprint

#Install Octoprint
#RUN git clone --branch $tag https://github.com/foosel/OctoPrint.git /opt/octoprint \
#  && virtualenv venv \
# && ./venv/bin/python setup.py install

# Install OctoPrint
RUN cd /opt/octoprint \
    && virtualenv venv \
    && source venv/bin/activate \
    && pip install pip --upgrade \
    && pip install https://get.octoprint.org/latest

VOLUME /home/octoprint/.octoprint


CMD ["/opt/octoprint/venv/bin/octoprint", "serve"]
