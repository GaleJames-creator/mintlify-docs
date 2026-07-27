FROM stoplight/prism:4
COPY api-reference/api-reference-bookhub-publisher-v2.yaml /tmp/spec.yaml
CMD ["mock", "-h", "0.0.0.0", "-p", "10000", "/tmp/spec.yaml"]