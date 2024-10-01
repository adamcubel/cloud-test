FROM redhat/ubi9

USER root
COPY scripts/ /scripts

RUN /bin/bash /scripts/install-prereq.sh

RUN groupadd -g 2000 internal && useradd -ms /bin/bash developer -G wheel -G internal -u 1001 -p "$(openssl passwd -1 developer)"

RUN mv /scripts/setup-user.sh /home/developer && \
    chown developer:developer /home/developer/setup-user.sh

USER developer

RUN /bin/bash /home/developer/setup-user.sh
