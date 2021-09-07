# call_app

This application is a proof of concept on how to invoke the app via incoming call service
The project was achieve with below packages

firebase_messaging (FCM)
callkeep

The app was tested on android for now

clone this repo and run 

`git clone https://github.com/adolfokrah/demo_call_app.git`

`cd demo_call_app`

`pod install`

`flutter run`

After the application is successfully built

Replace <YOUR_DEVICE_ID_TOKEN> with the FCM Token printed in the console and run the following curl command.

`// curl -X POST --header "Authorization: key=AAAAHx5B794:APA91bFg3-mmTAyRhruxK3AE4lPjKpXASpwTiqeWXHBmVD-UfaeIwxWy-B05o5ELQBSMQY7wVyEA6T6HykI2FPlg-C05GmQksnshmp84m7wgOwU1xFVrqJGTCcX0KfD9bziC6RmEqeXw" \
// --Header "Content-Type: application/json" \
// https://fcm.googleapis.com/fcm/send \
// -d "{\"to\":\"<YOUR_DEVICE_ID_TOKEN>\",\"notification\":{\"title\":\"Hello\",\"body\":\"Yellow\"}}"`

