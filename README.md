pushmenu
=============

Push notifications from you Mac to your iOS device via Prowl, Notifo or Boxcar. 

pushmenu is a small menu bar application that sends the content of you clipboard as 
push notification to your iOS device. You need to have at least one of the above push message
services installed on your device.

Features:

* Pushes clipboard content 
* Provides system service to push any selected text without copying to the clipboard first
* Keyboard shortcut
* AppleScript support (e.g. for Automator, Terminal)
* Credentials are stored in system keychain
* Automatic updates via Sparkle
* Growl support


![pushmenu](https://github.com/kalcher/pushmenu/raw/master/pushmenu/screenshot.png)
![](http://1pix.me/redirect.php?token=da37adeaf2&image=white.png)

AppleScript
------------
The AppleScript interface to pushmenu currently consists of one command with one parameter:

*sendmessage text : a text parameter passed to pushmenu*

The message is pushed out to all active services.

#### Example (push.scpt):

    on run {input}
	    tell application "pushmenu"
		    sendmessage input
	    end tell
    end run

Terminal
-----------
The AppleScript interface can also be used to provide terminal access to pushmenu. You need to have the above script (push.scpt) compiled and saved.

#### Example:
Run in Terminal:

    osascript /path/to/push.scpt "Hello World"

The script can be compiled with the AppleScript-Editor or also from Terminal

	osacompile -e"on run {input}" -e"tell application \"pushmenu\"" -e"sendmessage input"  -e"end tell" -e"end run" -o push.scpt
	
License
-----------

Copyright (c) 2011, Sebastian Kalcher.  All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of Sebastian Kalcher nor the names of the contributors
  may be used to endorse or promote products derived from this software
  without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL SEBASTIAN KALCHER BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.