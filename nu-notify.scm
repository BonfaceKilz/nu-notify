(define (run-unix-cmd cmd)
  ;;; Print to stdout on error
  ;;; TODO: save to local redis queue instead
  (let ((pid (system cmd)))
    (if (> (status:exit-val pid) 0)
        (begin
          (display "Pid value:") (display pid)
          (newline)
          (display "Status exit value:") (display (status:exit-val pid)) (newline)
          (display "Status term sig:") (display (status:term-sig pid)) (newline)
          (display "Status stop sig:") (display (status:stop-sig pid)) (newline)
          ))
    )
  )
