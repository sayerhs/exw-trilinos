FROM exawind/exw-dev-deps as base

ARG ENABLE_OPENMP=OFF
ARG ENABLE_CUDA=OFF
COPY cmake-configure.sh /cmake-configure.sh
RUN (\
    git clone --depth 1 -b develop https://github.com/trilinos/trilinos.git \
    && cd trilinos \
    && mkdir build \
    && cd build \
    && /cmake-configure.sh \
    && ninja -j$(nproc) \
    && ninja install \
    && cd ../.. \
    && rm -rf trilinos \
    && cd /opt/exawind/lib \
    && ls *so* | xargs strip -s \
    && echo "/opt/exawind/lib" > /etc/ld.so.conf.d/exawind.conf \
    && ldconfig \
    )

FROM exawind/exw-osrun as runner

COPY --from=base /usr/local /usr/local
COPY --from=base /opt/exawind /opt/exawind

RUN (\
    echo "/opt/exawind/lib" > /etc/ld.so.conf.d/exawind.conf \
    && ldconfig \
    )

ENV PATH /opt/exawind/bin:${PATH}
