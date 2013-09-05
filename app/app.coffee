app = angular.module('fbNotifier', ['ngGrid'])

.controller 'NotifierCtrl', ($scope, $filter, notificationSvc) ->

	$scope.total = 0
	$scope.users = "790128571\n100000882665737\n100000856290659\n100000354163834"
	$scope.notifications = []
	$scope.grid = { data: 'notifications' }
	$scope.button = "Start!"
	
	$scope.startStopNotifications = (form) ->
		if $scope.button is "Start!" and form.$valid is true
			$scope.button = "Notifying... (PRESS AGAIN TO STOP)"
			users = $scope.users.split("\n")
			$scope.total = users.length
			notify(users)
		else
			$scope.button = "Stopping..." if $scope.button isnt "Start!"

	logNotification = (user, status) ->
		$scope.notifications.push({ user: user, status: status, time: $filter('date')(Date.now(), "mediumTime")})
	
	nextUser = (users) -> 
		users.shift()

	endOrContinue = (users) ->
		if users.length > 0 and $scope.button isnt "Stopping..."
			notify(users) # continue
		else
			$scope.button = "Start!" # end

	notify = (users) ->
		user = nextUser(users)
		$scope.users = users.join("\n")

		notificationSvc.notify($scope.appToken, user, $scope.url, $scope.text, $scope.ref)
			.success (data) -> 
				logNotification(user, "OK")
				endOrContinue(users)
			.error (err) -> 
				logNotification(user, if err.error? then err.error.message else "Unknown error - see browser console" )
				endOrContinue(users)

.service 'notificationSvc', ($http) ->
	@notify = (token, user, url, text, ref = "") ->
		text = text.replace('@USER', "@[#{user}]")
		$http.post "https://graph.facebook.com/#{user}/notifications", null,
					{ params: { access_token: token, template: text, href: url, ref: ref} }
