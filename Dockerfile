FROM stoplight/prism:4
COPY api-reference/api-reference-bookhub-publisher-v2.yaml /tmp/spec.yaml
ENTRYPOINT []
CMD sh -c "prism mock -h 0.0.0.0 -p ${PORT:-4010} /tmp/spec.yaml"