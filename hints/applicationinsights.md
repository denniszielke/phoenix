# Monitoring and understanding application behaviour

Application Insights is an extensible Application Performance Management (APM) service for web developers on multiple platforms. Use it to monitor your live web application. It will automatically detect performance anomalies

## How do I create a secret for application insights?
```
APPINSIGHTS_KEY=HereBeYourKey
kubectl create secret generic appinsightsecret --from-literal=appinsightskey=$APPINSIGHTS_KEY
```

## Creating application insights
After you have set up Application Insights on your project, telemetry data about your app's performance and usage will appear in your project's Application Insights resource in the Azure portal.

https://docs.microsoft.com/en-us/azure/application-insights/app-insights-create-new-resource 

## How do I monitor the performance of by app?
Azure Application Insights can alert you to changes in performance or usage metrics in your web app.

https://docs.microsoft.com/en-us/azure/application-insights/app-insights-web-monitor-performance

## How do I monitor the availability of my website?

After you've deployed your web app or web site to any server, you can set up tests to monitor its availability and responsiveness.

https://docs.microsoft.com/en-us/azure/application-insights/app-insights-how-do-i
