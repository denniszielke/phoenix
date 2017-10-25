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
}

func main() {
	var appInsightsKey = os.Getenv("INSTRUMENTATIONKEY")
	var port = os.Getenv("PORT")
	client := appinsights.NewTelemetryClient(appInsightsKey)
	client.TrackEvent("gobackend-initializing")
	router := mux.NewRouter()
	router.HandleFunc("/ping", GetPing).Methods("GET")
	router.HandleFunc("/api/dummy", GetPing).Methods("GET")
	router.HandleFunc("/api/calculation", GetCalculation).Methods("POST")
	fmt.Println("Listening on " + port)
	http.ListenAndServe(":" + port, router)
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
	client.TrackEvent("calculation-gobackend-call")
	var input int
	var numberString string
	numberString = req.Header.Get("number")
	fmt.Println(req.Header.Get("number"))
	input, _ = strconv.Atoi(numberString)
	fmt.Println(input)
	var primestr string
	primestr = Factors(input);
	fmt.Println(primestr)
	var calcResult = Calculation{Value: "[" + primestr + "]",  Timestamp: time.Now()}
	elapsed := time.Since(start)
	var milliseconds =  int64(elapsed / time.Millisecond)
	client.TrackEvent("calculation-gobackend-result")
	client.TrackMetric("calculation-gobackend-duration", float32(milliseconds));
	fmt.Println("Responded with [" + primestr + "] in " + strconv.FormatInt(milliseconds, 10) +"ms")
	outgoingJSON, error := json.Marshal(calcResult)
	if error != nil {
		log.Println(error.Error())
		http.Error(res, error.Error(), http.StatusInternalServerError)
		return
	}
	fmt.Fprint(res, string(outgoingJSON))
}