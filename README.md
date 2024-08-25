# DEAL64

This...thing is an "encoding" algorithm.
My goal was to try and make some kind of argument parser (eh) and then reimplement in Dart an algorithm I created some time ago.

It's called DEAL64, "*Dan's Encoding ALgorithm, 64 security researchers will laugh at you*".
I quote "encoding" because it's not the right term to use for this, but I also don't think "encryption" is any better.

The algorithm just smashes together the message you want to hide, as well as the "key" + some additional info to recompose the message back together. But the process is easily reversible. It also largely increases the amount of data you want to transfer/hide/or whatever.

Do whatever you want with this (literally, see the license), I did it for fun and practice.
