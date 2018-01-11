FROM ubuntu:16.04
MAINTAINER icaro[at]swapy.network

ARG TAG=0.0.2-ALPHA
ENV SWAPY_EXCHANGE_REPOSITORY https://github.com/swapynetwork/swapy-exchange
ENV NETWORK_NAME "ropsten or rinkeby"
ENV NETWORK_ID "3 or 4"
ENV HTTP_PROVIDER "https://${NETWORK_NAME}.infura.io/yourKey"
ENV WS_PROVIDER ""
ENV TEST_RPC_PROVIDER "http://localhost:8545"
ENV DAPP_ENV test
ENV ENV_CONTENT "{\"HTTP_PROVIDER\": \"${HTTP_PROVIDER}\", \"TEST_RPC_PROVIDER\": \"${TEST_RPC_PROVIDER}\", \"WS_PROVIDER\": \"${WS_PROVIDER}\", \"BLOCK_EXPLORER_URL\": \"https://${NETWORK_NAME}.etherscan.io/address/\", \"ENV\": \"${DAPP_ENV}\", \"NETWORK_ID\": \"${NETWORK_ID}\", \"NETWORK_NAME\": \"${NETWORK_NAME}\"}"
ENV SWAPY_USER swapy
ENV SWAPY_PASSWORD 123456
ENV SWAPY_HOME /home/${SWAPY_USER}


# Install environment dependencies
RUN apt-get update && apt-get install -y nano vim git curl make gcc build-essential g++ apt-utils
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash
RUN apt-get install -y nodejs

# Create user ${SWAPY_USER}
RUN useradd -ms /bin/bash ${SWAPY_USER} && \
    echo "${SWAPY_USER}:${SWAPY_PASSWORD}" | chpasswd

# Go on user
USER ${SWAPY_USER}
WORKDIR ${SWAPY_HOME}

# Config npm global dir
RUN mkdir ${SWAPY_HOME}/.npm-global && \
    npm config set prefix ${SWAPY_HOME}/.npm-global && \
    echo "export PATH=${SWAPY_HOME}/.npm-global/bin:$PATH" >> ${SWAPY_HOME}/.profile && \
    export PATH=${SWAPY_HOME}/.npm-global/bin:$PATH && \
    npm install -g pm2 http-server webpack @angular/cli && \
    alias ng="${SWAPY_HOME}/.npm-global/lib/node_modules/@angular/cli/bin/ng"

# Clone and build Swapy Exchange
RUN mkdir ./www && \
    export PATH=${SWAPY_HOME}/.npm-global/bin:$PATH && \
    cd ./www && \
    git clone ${SWAPY_EXCHANGE_REPOSITORY} && \
    cd ./swapy-exchange && \
    git checkout tags/${TAG} && \
    echo "${ENV_CONTENT}" > env.json && \
    npm install
EXPOSE 4200
WORKDIR ${SWAPY_HOME}/www/swapy-exchange
CMD npm run alpha