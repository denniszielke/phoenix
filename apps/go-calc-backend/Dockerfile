FROM golang:latest 
RUN mkdir /app 
COPY ./app/* /app/
WORKDIR /app 
RUN go get github.com/gorilla/mux
RUN go get github.com/Microsoft/ApplicationInsights-Go/appinsights
RUN go build -o main . 
EXPOSE 80
CMD ["/app/main"]