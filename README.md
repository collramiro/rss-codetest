# rss-codetest

Until now I spent 8hs between reading the API, designing the storyboard on paper and coding.

![](/paperstoryboard.jpg)

Instructions:
- To run the project you need to do a pod install at the project folder first.

Current functionalities:
- Login/Register 
  - The app stores the user, so if you kill the app and reopen, you'll be logged in. Anyway this need improvements to avoid expiration of authtoken.
- Home includes:
  - EmptyDataSet-Swift to manage empty tableview and suggest the user to add feed sources.
  - Remove feeds with native management.
  - Add more feeds from a local list.
- Articles list:
  - Just list articles from the selected feed.
- Custom WKWebView:
  - I did this for a previous project, is a custom implementation of a webview with nice UI for showing loading progress and swipe for dismissing. It's super easy to add back/forward/refresh actions. It's a clone from Facebook InApp WebView.
  

Important Pendings:
- Manage authtoken expiration
- Manage no internet connection in a better way
- Implement refresh feed
- Implement read article
- Pull to refresh at list
- Lots of UI/UX improvements
- Lots of testing (Maybe unit cases also)
- There is a weird bug that sometimes shows an error with the connection even when should be fine. Needs more testing.
