;; Debris Tracking Contract

(define-data-var next-debris-id uint u0)

(define-map debris-objects
  { debris-id: uint }
  {
    name: (string-ascii 64),
    size: uint,
    orbit-height: uint,
    last-updated: uint
  }
)

(define-public (register-debris (name (string-ascii 64)) (size uint) (orbit-height uint))
  (let
    ((debris-id (+ (var-get next-debris-id) u1)))
    (var-set next-debris-id debris-id)
    (ok (map-set debris-objects
      { debris-id: debris-id }
      {
        name: name,
        size: size,
        orbit-height: orbit-height,
        last-updated: block-height
      }
    ))
  )
)

(define-public (update-debris-location (debris-id uint) (new-orbit-height uint))
  (let
    ((debris (unwrap! (map-get? debris-objects { debris-id: debris-id }) (err u404))))
    (ok (map-set debris-objects
      { debris-id: debris-id }
      (merge debris {
        orbit-height: new-orbit-height,
        last-updated: block-height
      })
    ))
  )
)

(define-read-only (get-debris-info (debris-id uint))
  (map-get? debris-objects { debris-id: debris-id })
)

(define-read-only (get-debris-count)
  (var-get next-debris-id)
)

