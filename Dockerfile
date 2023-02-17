FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y sudo git curl unzip build-essential lld cmake clang llvm
RUN apt-get install -y libssl-dev pkg-config
RUN apt-get install -y libpq-dev lcov

WORKDIR /root
COPY build_test /root/

# Install rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN rustup component add rustfmt
RUN rustup component add clippy

RUN cargo install cargo-sort --locked
RUN cargo install cargo-nextest --locked
RUN cargo install grcov --version=0.8.2 --locked
RUN cargo install protoc-gen-prost
RUN cargo install protoc-gen-prost-serde
RUN cargo install protoc-gen-prost-crate

RUN git clone https://github.com/aptos-labs/aptos-core.git
RUN cd ~/aptos-core/sdk && cargo build

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs
RUN npm install --global yarn
RUN yarn add aptos

# Install python
RUN apt-get install -y python3-all-dev python3-setuptools python3-pip
RUN pip3 install aptos-sdk schemathesis pre-commit boto3

RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:${PATH}"
RUN cd ~/aptos-core/ecosystem/python/sdk && poetry update

# Install aptos cli
RUN curl -O -L https://github.com/aptos-labs/aptos-core/releases/download/aptos-cli-v1.0.0/aptos-cli-1.0.0-Ubuntu-22.04-x86_64.zip
RUN unzip aptos-cli-1.0.0-Ubuntu-22.04-x86_64.zip && mv aptos /usr/local/bin

# Install remaining
RUN cd ~/aptos-core && ./scripts/dev_setup.sh -b

RUN cd /root/build_test && python3 first_move_module.py
