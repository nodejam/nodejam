# What's Fora
A platform for building end-to-end Isomorphic JS apps.

Fora's builds on the significance of every shipping browser also including a debugging and dev environment for JavaScript.
Which means that if the stack is entirely JavaScript, you could develop/test in a browser and expect it to run with Node.JS on the Server.
- Fora is an Build System + App Store + IDE for "End-to-End Isomorphic" JS Apps.
- End-to-End Isomorphism? We've gotten the Web Server, App and the Db (MongoDb initially) to run entirely within the browser
- The App Store will feature (eventually) apps in various categories, like Publishing, Social Service, Travel ...
- Most Apps will be Open Source, but there'll be an Enterprise Version
- Any user can Fork, Edit and Debug an existing app within just the browser (we've an IDE, based on http://ace.c9.io/)
- You can set breakpoints for Business Logic and Db inside the browser (since Fora's Mongo API runs in the browser)
- Once they make a worthwhile change, they may also send pull requests to the original maintainer
- These apps can also be provisioned and deployed on a Server (which will be a paid service)
- In Phase 2, we'll support all compile to JS languages (like Java, Python, LISP, Dart etc)

The platform preview is ready, but at this point we're working on *docs and examples*.
- We were planning to do this by June 1st week, but it might take a month more. Apologies.
- We will also be switching the licenses for all Fora Projects from GPL3 to MIT.

If you're adventurous:
```
npm install -g fora
fora install fora-template-fora-appstore
fora new fora-appstore somedir
cd somedir
fora build
```
