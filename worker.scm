#!/usr/local/bin/guile -s
!#

;;; (nu-notify-worker) --- Notification worker for Guile

;; Copyright (C) 2019 Bonface M. K.

;; Author: Bonface M. K.
;; Keywords: notification, monitoring
;; Package-Requires: ((redis))

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.


;;; Commentary:

;; Dequeue messages from redis

;;; Code:
(use-modules (redis))
(use-modules (rnrs bytevectors))
(use-modules (ice-9 iconv))
(use-modules (ice-9 binary-ports))
(use-modules (ice-9 textual-ports))
(use-modules (ice-9 rdelim))

(define conn (redis-connect))

(define (dequeue-error conn)
  "Remove the error from the queue"
  (begin
    (display (redis-send conn (lpop '(queue:error))))
    (redis-close conn)
    (newline)))

(define (redis-sock-get conn)
  "Get a socket from the connection"
  (let ((get-sock
	 (record-accessor
	  (record-type-descriptor conn)
	  (caddr (record-type-fields (record-type-descriptor conn))))))
    (get-sock conn)))

(define (subscribe-listen redis-sock)
  "Listener for the error channel"
  (let ((sub-buf (make-bytevector 1024)))
    (recv! redis-sock sub-buf)
    (display (read-delimited
	      "\0"
	      (open-input-string (bytevector->string sub-buf "utf8"))))
    (newline)
    (dequeue-error (redis-connect))      
    (subscribe-listen redis-sock)))

(define redis-socket (redis-sock-get conn))

(redis-send conn (subscribe '(channel:error)))
(subscribe-listen redis-socket)

;;; nu-notify-worker ends here
