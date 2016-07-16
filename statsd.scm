(use srfi-1 srfi-4 srfi-12 srfi-13 srfi-28 srfi-69)

(use udp)

;; Generic statsd client
(define (statsd:send statsd-host statsd-port metric)
  (let ((sock (udp-open-socket)))
        (udp-connect! sock statsd-host statsd-port)
         (udp-send sock metric)
         (udp-close-socket sock)))

;; Send a gauage to statsd, item needs to a be pair
;; stats key will be built out of stats-previs.(first pair)
(define (statsd:-> statsd-host statsd-port metric-path value type)
  (let ((metric (format "~A:~A|~A"
                        metric-path
                        value
                        type)))
    (statsd:send
     statsd-host statsd-port
     metric)))

;; these simply implement types outlined here:
;; https://github.com/etsy/statsd/blob/master/docs/metric_types.md
(define (statsd:gauge host port name value)
  (statsd:-> host port name value "g"))

(define (statsd:counter host port name value)
  (statsd:-> host port name value "c"))

(define (statsd:counter-with-rate host port name value rate)
  (statsd:-> host port name value (format "c|@~A" rate)))

(define (statsd:timing host port name value)
  (statsd:-> host port name value "ms"))

(define (statsd:timing-with-rate host port name value rate)
  (statsd:-> host port name value (format "ms|@~A" rate)))

;; XXX: this could have been a macro and it would be fun to
;; write it, but at this point it's fine
(define (statsd:with-timing host port name fn)
  (let* ((start-time (current-milliseconds))
         (res (fn))
         (end-time (current-milliseconds)))
    (statsd:timing host port name (- end-time start-time))
    res))
