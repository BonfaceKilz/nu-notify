(use-modules (ice-9 format)
             (redis))

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
