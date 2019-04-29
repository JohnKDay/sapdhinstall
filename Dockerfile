FROM ubuntu:latest

RUN apt-get update && apt-get install -y curl python-pip ruby wget jq bash-completion apt-transport-https sudo gnupg2 git tmux openssh-server vim && \
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install --no-install-recommends -y kubectl=1.12.6-00 && \
    pip install awscli && \
    curl -s https://api.github.com/repos/kubernetes-sigs/aws-iam-authenticator/releases/latest | grep "browser_download.url.*linux_amd64" | cut -d : -f 2,3 | tr -d '"' | wget -O /usr/local/bin/aws-iam-authenticator -qi - && chmod 555 /usr/local/bin/aws-iam-authenticator && \
    curl -s https://api.github.com/repos/GoogleContainerTools/skaffold/releases/latest | grep "browser_download.url.*linux-amd64.$" | cut -d : -f 2,3 | tr -d '"' | wget -O /usr/local/bin/skaffold -qi - && chmod 555 /usr/local/bin/skaffold && \
    curl -sq https://storage.googleapis.com/kubernetes-helm/helm-v2.10.0-linux-amd64.tar.gz| tar zxvf - --strip-components=1 -C /usr/local/bin linux-amd64/helm && \
    curl -sq https://download.docker.com/linux/static/stable/x86_64/docker-18.09.1.tgz | tar zxvf - --strip-components=1 -C /usr/local/bin docker/docker && \
    rm -rf /var/lib/apt/lists/*

COPY SAPDH /root/SAPDH
COPY bin/* /usr/local/bin/

# Configure SSHD
RUN mkdir /var/run/sshd
RUN echo 'root:sapdhinstall' | chpasswd
RUN useradd -ms /bin/bash ccpuser
RUN echo 'ccpuser:sapdhinstall' | chpasswd
RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN echo 'export DOCKER_HOST=tcp://localhost:2375' >> /etc/environment


#CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]
