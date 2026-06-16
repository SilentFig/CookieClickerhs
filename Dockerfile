FROM haskell:latest AS builder

WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    libpq-dev \
    pkg-config

COPY . .

RUN stack build --install-ghc --copy-bins --local-bin-path /out

FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y \
    libpq5 \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /out/cookie-clicker-exe /usr/local/bin/cookie-clicker-exe

CMD ["cookie-clicker-exe"]