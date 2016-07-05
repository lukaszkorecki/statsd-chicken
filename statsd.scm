(use srfi-1 srfi-4 srfi-12 srfi-13 srfi-28 srfi-69)

(use udp)


;; Generic statsd client
(define (send-to-statsd statsd-host statsd-port key type value)
  (let* ((sock (udp-open-socket))
         (payload (format "~A:~A|~A\n"
                          key
                          value
                          type)))

    (printf ">statsd>: ~A" payload)
    (udp-connect! sock statsd-host statsd-port)
    (udp-send sock payload)
    (udp-close-socket sock)))

;; Send a gauage to statsd, item needs to a be pair
;; stats key will be built out of stats-previs.(first pair)
(define (->to-statsd stat-prefix item)
  (let ( (qname (first item))
         (value (last item)))

    (send-to-statsd
     statsd-host statsd-port
     (format "~A.~A" stat-prefix qname)
     "g"
     value)))
