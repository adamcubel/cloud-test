FROM redhat/ubi9

USER root
COPY scripts/ /scripts

RUN /bin/bash /scripts/install-prereq.sh

# Remove all repos in container image
RUN for i in $(yum repolist | awk '{print $1}' |tail -3);do yum config-manager --set-disabled $i; done

USER developer
