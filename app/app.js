var app = angular.module('fbNotifier', ['ngGrid']);

app.controller('NotifierCtrl', function($scope, $timeout, notificationSvc) {

	function notify(users) {
		var user = users.shift(); // pick next user

		var always = function() { // always run in the end of notification
			$scope.users = users.join("\n");
			if (users.length > 0 && $scope.button != 'Stopping...') {
				notify(users); // keep notifying
			}
			else {
				$scope.button = "Start!";
			}
		}

		notificationSvc.notify($scope.appToken, user, $scope.url, $scope.text)
		.success(function(data) {
				$scope.notifications.push({user: user, status: "OK"});
			})
		.error(function(err) {
				$scope.notifications.push({user: user, status: err.error.message });
			})
		.then(always, always);
	}

	$scope.appToken = "";
	$scope.total = 0;
	$scope.users = "790128571\n100000882665737\n100000856290659\n100000354163834";
	$scope.notifications = [];
	$scope.grid = { data: 'notifications' };
	$scope.button = "Start!";
	$scope.text = "";
	$scope.url = "";

	$scope.startStopNotifications = function() {
		if ($scope.button == 'Start!') {
			$scope.button = "Notifying... (PRESS TO STOP)"
			var users = $scope.users.split("\n");
			$scope.total = users.length;
			notify(users);
		}
		else
		{
			$scope.button = "Stopping...";
		}
	}
});

app.service('notificationSvc', function($http) { 
	this.notify = function(token, user, url, text, ref) {
		ref = ref || '';
		text = text.replace('@USER', '@[' + user + ']');
		return $http.post('https://graph.facebook.com/' + user + 
							'/notifications?access_token=' + token + 
							'&template=' + text +
							'&href=' + url +
							'&ref=' + ref);
	}
});
