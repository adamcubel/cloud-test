FROM redhat/ubi9

USER root
COPY scripts/ /scripts

RUN /bin/bash /scripts/install-prereq.sh

# Remove all repos in container image
RUN for i in $(yum repolist | awk '{print $1}' |tail -3);do yum config-manager --set-disabled $i; done

RUN groupadd -g 2000 internal && useradd -ms /bin/bash developer -G wheel -G internal -u 1001 -p "$(openssl passwd -1 developer)"

RUN mv /scripts/install-prereq.sh /home/developer &&
    chown developer:developer /home/developer/install-prereq.sh
USER developer

RUN /bin/bash /home/developer/install-prereq.sh
