(use-modules (redis))

(define (dequeue-error conn)
  (begin
    (display (redis-send conn (lpop '(queue:error))))
    (newline)
    (redis-close conn)))
