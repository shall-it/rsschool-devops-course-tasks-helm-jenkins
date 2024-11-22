FROM docker.io/library/golang:1.23-alpine AS builder
WORKDIR /word-cloud-generator
RUN apk add --no-cache git make && \
    git clone https://github.com/Fenikks/word-cloud-generator.git . && \
    make

FROM scratch
WORKDIR /app
COPY --from=builder /word-cloud-generator/artifacts/linux/word-cloud-generator .
CMD ["/app/word-cloud-generator"]