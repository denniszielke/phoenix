var apiUrl = '/api/';

function loopClick() {
    console.log(document.getElementById('triggerButton'));
    document.getElementById('triggerButton').click();
};

angular.module('CalculatorApp', [])
    .controller('CalculatorController',
        function ($scope, $http) {
            $scope.Calculate = function () {
                var postUrl = apiUrl + 'calculation';
                var config = {
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8;',
                        'number': $scope.id
                    }
                };

                $http.post(postUrl, { 'number': $scope.id, 'key': $scope.key }, config)
                    .success(function (response) { 
                        $scope.result = response;
                        console.log(response);
                        if ($scope.loop){
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
            }            
        }
    );