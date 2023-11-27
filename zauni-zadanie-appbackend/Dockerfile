# Multi-stage build docker file

# app build stage
FROM golang:alpine as builder
RUN mkdir /build 
ADD . /build/
WORKDIR /build 
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o main .

# image build image - use scratch to get smallest possible size of an image
FROM scratch
WORKDIR /app
COPY --from=builder /build/main .

EXPOSE 9080

ENTRYPOINT [ "./main" ]

## TODO:
# Prikaz COPY, ktory poznate, je mozne pouzit aj na kopirovanie suborov, ktore vznikli v predchadzajucom stage, tj:
# COPY --from=<stage_name> source target
# V nasom pripade sa predchadzajuci stage vola: builder (vsimnite si pomenovanie na riadku c. 4)
# Vasou ulohou je:
#  1. pridat prikaz, ktory skopiruje zo stage builder subor: /builder/main do adresara /app/ (vsimnite si na riadku c.8, ze vystupom kompilacie je subor s nazvom main)
#  2. nastavit pracovny adresar (workdir) na: /app
#  3. pridat instrukciu, ktora zabezpeci, ze po vytvoreni kontajnera sa spusti aplikacia (tj. ./main)
