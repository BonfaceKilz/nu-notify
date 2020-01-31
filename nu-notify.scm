;;; (nu-notify) --- Simple notifications for Guile

;; Copyright (C) 2019 Bonface M. K.

;; Author: Bonface M. K.
;; Keywords: notification, monitoring
;; Package-Requires: ((redis) (ice-9 format))

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

;; Queue messages into redis

;;; Code:

(use-modules (redis)
             (ice-9 format))

(define (enqueue-error error-message conn)
  (let ((error-sexp (format #f "~a" error-message)))
    (begin
      (redis-send conn (lpush `(queue:error ,error-sexp)))
      (redis-close conn))))

(define (run-unix-cmd cmd)
  ;;; Run command command and on error,
  ;;; enqueue the PID to a redis queue
  (let ((pid (system cmd)))
    (if (> (status:exit-val pid) 0)
        (enqueue-error `((command . ",cmd")
                         (pid . ,pid))
                       (redis-connect)))))

;;; nu-notify ends here
