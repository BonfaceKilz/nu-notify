(use-modules (ice-9 format)
             (redis))

(define (enqueue-error error-message conn)
  (begin
    (redis-send conn (lpush `(queue:error ,error-message)))
    (redis-close conn)))

(define (run-unix-cmd cmd)
  ;;; Run command command and on error,
  ;;; enqueue the PID to a redis queue
  (let ((pid (system cmd)))
    (if (> (status:exit-val pid) 0)
        (enqueue-error (format #f "[Error] PID: ~d Command: ~a" pid cmd)
                 (redis-connect)))))
