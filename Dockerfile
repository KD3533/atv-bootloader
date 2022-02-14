FROM ubuntu:latest

WORKDIR /opt/

RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y wget libc6:i386 libgcc1:i386 libstdc++5:i386 libstdc++6:i386
RUN wget https://web.archive.org/web/20160229085013if_/http://atv-bootloader.googlecode.com/files/darwin-cross.tar.gz
RUN tar -xvzf darwin-cross.tar.gz
RUN tar -xvzf darwin-cross/darwin-cross.tar.gz
RUN rm **/.DS_Store darwin-cross.tar.gz darwin-cross/darwin-cross.tar.gz

# set up prefixed and non-prefixed aliases to each entry in darwin-cross/bin (just `gcc` defaults to 4.0.1)

RUN ls -1 darwin-cross/bin/ | awk -F "-" '{system("ln -fs /opt/darwin-cross/bin/"$0" /usr/bin/"$0)}'
RUN ls -1 darwin-cross/bin/ | awk -F "-" '{system("ln -fs /opt/darwin-cross/bin/"$0" /usr/bin/"$4)}'
