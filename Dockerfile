#Initial stage: download modules
FROM golang:1.13 as modules

ADD go.mod go.sum /m/
RUN cd /m && fo mod download

# Intermediate stage: Build the binary
FROM golang:1.13 as builder

COPY --from=modules /go/pkg /go/pkg    ### копирование модуля из предыдущего шага

#add a non-privileged user
RUN useradd -u 10001 myapp  ### добавим юзера в контейнер, чтобы был не ROOT

RUN mkdir -p /mmyapp			###
ADD . /myapp					###		директория где будет храниться исходный код
WORKDIR /myapp					###

#Build the binary with go builder
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 \				### сама компиляция
go build -o ./bin/myapp .

# Final stage: Run the binary
FROM scracth

# pass from previous stage
COPY --from=builder /etc/passwd etc/passwd
USER myapp

# our binary out
COPY --from=builder /myapp/bin/myapp /myapp

CMD ["/myapp"]
