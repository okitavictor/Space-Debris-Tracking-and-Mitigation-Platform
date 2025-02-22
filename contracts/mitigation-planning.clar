;; Mitigation Planning Contract

(define-data-var next-mission-id uint u0)

(define-map mitigation-missions
  { mission-id: uint }
  {
    target-debris-id: uint,
    status: (string-ascii 20),
    assigned-to: (optional principal),
    planned-date: uint
  }
)

(define-public (create-mitigation-mission (target-debris-id uint) (planned-date uint))
  (let
    ((mission-id (+ (var-get next-mission-id) u1)))
    (var-set next-mission-id mission-id)
    (ok (map-set mitigation-missions
      { mission-id: mission-id }
      {
        target-debris-id: target-debris-id,
        status: "Planned",
        assigned-to: none,
        planned-date: planned-date
      }
    ))
  )
)

(define-public (assign-mission (mission-id uint) (assignee principal))
  (let
    ((mission (unwrap! (map-get? mitigation-missions { mission-id: mission-id }) (err u404))))
    (ok (map-set mitigation-missions
      { mission-id: mission-id }
      (merge mission {
        status: "Assigned",
        assigned-to: (some assignee)
      })
    ))
  )
)

(define-public (update-mission-status (mission-id uint) (new-status (string-ascii 20)))
  (let
    ((mission (unwrap! (map-get? mitigation-missions { mission-id: mission-id }) (err u404))))
    (asserts! (is-eq (some tx-sender) (get assigned-to mission)) (err u403))
    (ok (map-set mitigation-missions
      { mission-id: mission-id }
      (merge mission { status: new-status })
    ))
  )
)

(define-read-only (get-mission-info (mission-id uint))
  (map-get? mitigation-missions { mission-id: mission-id })
)

