FROM debian:trixie-slim
RUN apt-get update
RUN apt-get install -y build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libisl-dev wget

RUN wget https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.gz
RUN mkdir binutils && tar -xzvf binutils-2.44.tar.gz -C binutils

RUN wget https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.gz
RUN mkdir gcc && tar -xzvf gcc-14.2.0.tar.gz -C gcc

ENV PREFIX="$HOME/opt/cross"
ENV TARGET=i386-elf
ENV PATH="$PREFIX/bin:$PATH"

RUN mkdir build-binutils
RUN ls
RUN cd build-binutils && \
../binutils/binutils-2.44/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror && \
make -j 8 && \
make install

RUN cd .. && \
mkdir build-gcc && \
cd build-gcc && \
../gcc/gcc-14.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx
RUN cd build-gcc -j 8 && \
make all-gcc -j 8 && \
make all-target-libgcc -j 8 && \
make all-target-libstdc++-v3 -j 8 && \
make install-gcc && \
make install-target-libgcc && \
make install-target-libstdc++-v3

RUN apt-get install -y grub2 mtools xorriso
RUN apt-get install -y nasm

WORKDIR /usr/src/Cornflower
