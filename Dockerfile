FROM scratch
ARG hello=123
CMD ["echo ${hello}"]
