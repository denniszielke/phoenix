package main

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"log"
	"net/http"
	"time"
	"os"

	"github.com/gorilla/mux"
	"github.com/Microsoft/ApplicationInsights-Go/appinsights"
)

type Calculation struct {
	Timestamp time.Time `json:"timestamp"`
	Value      string	`json:"value"`
	Host		string 	`json:"host"`
}

func main() {
	var appInsightsKey = os.Getenv("INSTRUMENTATIONKEY")
	var port = os.Getenv("PORT")

	if (len(appInsightsKey) > 0) {
		client := appinsights.NewTelemetryClient(appInsightsKey)
		client.TrackEvent("go-backend-initializing")
		client.Context().Tags.Cloud().SetRole("calc-backend-svc")
	}
	router := mux.NewRouter()
	router.HandleFunc("/ping", GetPing).Methods("GET")
	router.HandleFunc("/api/dummy", GetPing).Methods("GET")
	router.HandleFunc("/api/calculation", GetCalculation).Methods("POST")
	hostname, err := os.Hostname()
	if err != nil {
		panic(err)
	}
	fmt.Println("hostname:", hostname)	
	if (len(port) > 0 ) {
		http.ListenAndServe(":" + port, router)
	}else
	{
		port = "80"
		http.ListenAndServe(":" + port, router)
	}
	fmt.Println("Listening on " + port)
}

func GetPing(res http.ResponseWriter, req *http.Request) {
	res.Header().Set("Content-Type", "application/json")

	var calcResult = Calculation{Value: "42",  Timestamp: time.Now()}
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
	var appInsightsKey = os.Getenv("INSTRUMENTATIONKEY")
	client := appinsights.NewTelemetryClient(appInsightsKey)
	client.Context().Tags.Cloud().SetRole("calc-backend-svc")
	client.TrackEvent("calculation-go-backend-call")	
	var input int
	var numberString string
	numberString = req.Header.Get("number")
	fmt.Println(req.Header.Get("number"))
	input, _ = strconv.Atoi(numberString)
	fmt.Println(input)
	var primestr string
	primestr = Factors(input);
	fmt.Println(primestr)
	hostname, err := os.Hostname()
	if err != nil {
		panic(err)
	}
	var calcResult = Calculation{Value: "[" + primestr + "]", Timestamp: time.Now(), Host: hostname}
	elapsed := time.Since(start)
	var milliseconds =  int64(elapsed / time.Millisecond)
	client.TrackEvent("calculation-go-backend-result")
	client.TrackMetric("calculation-go-backend-duration", float64(milliseconds));
	fmt.Println("Responded with [" + primestr + "] in " + strconv.FormatInt(milliseconds, 10) +"ms")
	outgoingJSON, error := json.Marshal(calcResult)
	if error != nil {
		log.Println(error.Error())
		http.Error(res, error.Error(), http.StatusInternalServerError)
		return
	}
	fmt.Fprint(res, string(outgoingJSON))
}