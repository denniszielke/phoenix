var apiUrl = '/api/';

function loopClick() {
    console.log(document.getElementById('triggerButton'));
    document.getElementById('triggerButton').click();
};

angular.module('CalculatorApp', [])
    .controller('CalculatorController',
        function ($scope, $http) {

            $scope.Init = function () {
                console.log("init");
                var getUrl = apiUrl + 'getappinsightskey';
                var config = {
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8;'
                    }
                };
                if ($scope.id === undefined){
                    $scope.id = 42;
                    $scope.responses =  [];
                }

                $http.get(getUrl, {}, config)
                    .success(function (response) { 
                        $scope.appInsightsKey = response;
                        console.log(response);
                        initAppInsights($scope.appInsightsKey);
                    });                
            };

            $scope.CalculateCssClass = function(versionValue){
                if (versionValue && versionValue != undefined){
                    if (versionValue.toString().indexOf("blue") >= 0)
                        return "bg-info";
                    else if (versionValue.toString().indexOf("green") >= 0)
                        return "bg-green";
                    else
                        return "bg-yellow";
                }
            }

            $scope.Calculate = function () {
                var postUrl = apiUrl + 'calculation';
                var config = {
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8;',
                        'number': $scope.id
                    }
                };
                $scope.requeststartDate = new Date();
                window.appInsights.trackEvent("calculation-client-call-start", { value: $scope.id});
                $http.post(postUrl, { 'number': $scope.id }, config)
                    .success(function (response) { 
                        var endDate = new Date();
                        response.duration = endDate - $scope.requeststartDate
                        $scope.result = response;
                        $scope.responses.splice(0,0,response);
                        console.log("received response:");
                        console.log(response);
                        if (window.appInsights){
                            window.appInsights.trackEvent("calculation-client-call-end", { value: $scope.result});
                        }
                        if ($scope.loop){
                            var randomNumber = Math.floor((Math.random() * 10000000) + 1);
                            console.log(randomNumber);
                            $scope.id = randomNumber;
                            if (!$scope.frequency){
                                $scope.frequency = 500;
                            }
                            $scope.looping = false;
                            if (!$scope.looping)
                            {
                                window.setTimeout(loopClick, $scope.frequency);
                            }
                            $scope.looping = true;
                        }
                    });
            };
            
            $scope.Init();
        }
    );