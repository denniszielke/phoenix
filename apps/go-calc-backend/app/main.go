package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/Microsoft/ApplicationInsights-Go/appinsights"
	"github.com/gorilla/mux"
)

type Calculation struct {
	Timestamp time.Time `json:"timestamp"`
	Value     string    `json:"value"`
	Host      string    `json:"host"`
	Remote    string    `json:"remote"`
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/ping", GetPing).Methods("GET")
	router.HandleFunc("/healthz", GetPing).Methods("GET")
	router.HandleFunc("/api/dummy", GetPing).Methods("GET")
	router.HandleFunc("/api/calculation", GetCalculation).Methods("POST")

	hostname, err := os.Hostname()
	if err != nil {
		panic(err)
	}
	fmt.Println("hostname:", hostname)
	var appInsightsKey, appInsightsKeyExists = os.LookupEnv("INSTRUMENTATIONKEY")
	var client appinsights.TelemetryClient
	if appInsightsKeyExists && appInsightsKey != "dummyValue" {
		fmt.Println("appinsights set:", appInsightsKey)
		client = appinsights.NewTelemetryClient(appInsightsKey)
		client.TrackEvent("go-backend-initializing")
		client.Context().Tags.Cloud().SetRole("calc-backend-svc")
	} else {
		fmt.Println("appinsights not set")
		client = nil
	}

	var port, portExists = os.LookupEnv("PORT")
	if portExists {
		fmt.Println("port set:", port)
		fmt.Println("Listening on", port)
		http.ListenAndServe(":"+port, router)
	} else {
		port = "8080"
		fmt.Println("port default:", port)
		fmt.Println("Listening on", port)
		http.ListenAndServe(":"+port, router)
	}
}

func GetPing(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("Content-Type", "application/json")

	var calcResult = Calculation{Value: "42", Timestamp: time.Now()}
	outgoingJSON, error := json.Marshal(calcResult)
	if error != nil {
		log.Println(error.Error())
		http.Error(res, error.Error(), http.StatusInternalServerError)
		return
	}
	fmt.Fprint(res, string(outgoingJSON))
}

func Factors(n int) string {
	valuesText := []string{}
	var returnText string
	divisor := int(2)
	for rest := n; rest > 0; {
		divisor = factor(rest, divisor)
		if divisor == 0 {
			return returnText
		}
		var text = strconv.Itoa(divisor)
		valuesText = append(valuesText, text)
		returnText = strings.Join(valuesText, ",")
		rest = rest / divisor
	}
	fmt.Println(returnText)
	returnText = strings.Join(valuesText, ",")
	return returnText
}

func factor(n, divisor int) int {
	for i := divisor; i <= n; i++ {
		if n%i == 0 {
			return i
		}
	}
	return 0
}

func GetCalculation(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("Content-Type", "application/json")
	start := time.Now()
	var client appinsights.TelemetryClient
	var appInsightsKey, appInsightsKeyExists = os.LookupEnv("INSTRUMENTATIONKEY")
	if appInsightsKeyExists && appInsightsKey != "dummyValue" {
		client = appinsights.NewTelemetryClient(appInsightsKey)
		client.Context().Tags.Cloud().SetRole("calc-backend-svc")
		client.TrackEvent("calculation-go-backend-call")
	}
	var input int
	var numberString string
	numberString = req.Header.Get("number")
	fmt.Println(req.Header.Get("number"))
	input, _ = strconv.Atoi(numberString)
	fmt.Println(input)
	var primestr string
	primestr = Factors(input)
	fmt.Println(primestr)
	hostname, err := os.Hostname()
	if err != nil {
		panic(err)
	}
	var remoteip string
	remoteip = req.RemoteAddr
	var calcResult = Calculation{Value: "[" + primestr + "]", Timestamp: time.Now(), Host: hostname, Remote: remoteip}
	elapsed := time.Since(start)
	var milliseconds = int64(elapsed / time.Millisecond)
	if appInsightsKeyExists && appInsightsKey != "dummyValue" {
		client.TrackEvent("calculation-go-backend-result")
		client.TrackMetric("calculation-go-backend-duration", float64(milliseconds))
	}
	fmt.Println("Responded with [" + primestr + "] in " + strconv.FormatInt(milliseconds, 10) + "ms")
	outgoingJSON, error := json.Marshal(calcResult)
	if error != nil {
		log.Println(error.Error())
		http.Error(res, error.Error(), http.StatusInternalServerError)
		return
	}
	fmt.Fprint(res, string(outgoingJSON))
}
