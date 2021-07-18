FROM klakegg/hugo:latest

WORKDIR /joham

COPY ./joham /joham

ENTRYPOINT ["hugo", "server", "-D"]
