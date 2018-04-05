Authenticator
=============

This is a fork of the former [authenticator](https://launchpad.net/authenticator) app made for the Ubuntu phone platform, by Michael Zanetti.

Authenticator is an application that can be used for the two-factor
authentication for OATH compliant services. It currently supports both
HOTP (counter) and TOTP (timer) methods of one time password generation.

Data from the former authenticator app may be copied over:

```
mkdir -p ~/.config/authenticator-ng.dobey
cat ~/.config/com.ubuntu.developer.mzanetti.ubuntu-authenticator/ubuntu-authenticator.conf >> ~/.config/authenticator-ng.dobey/authenticator.conf
```

