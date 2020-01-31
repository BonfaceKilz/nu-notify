# nu-notify
### Description
A simple notification system built in Guile. `nu-notify` library provides a
wrapper to a UNIX command and when an error occurs, publishes it to an error
channel in REDIS after queueing it. Example usage:

```
(use-modules (nu-notify))

(run-unix-cmd "ls -a")
```

The worker on the other hand is a script that has subscribed to the error
channel. When a message is broad-casted to the channel, it dequeues items from
the error queue and prints it out on stdout. To run it:

```
guile worker.scm
```
