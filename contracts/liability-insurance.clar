;; Liability and Insurance Contract

(define-map insurance-policies
  { policy-id: uint }
  {
    owner: principal,
    coverage-amount: uint,
    premium: uint,
    expiration: uint
  }
)

(define-data-var next-policy-id uint u0)

(define-constant CONTRACT_OWNER tx-sender)

(define-public (create-policy (coverage-amount uint) (premium uint) (duration uint))
  (let
    ((policy-id (+ (var-get next-policy-id) u1))
     (expiration (+ block-height duration)))
    (var-set next-policy-id policy-id)
    (ok (map-set insurance-policies
      { policy-id: policy-id }
      {
        owner: tx-sender,
        coverage-amount: coverage-amount,
        premium: premium,
        expiration: expiration
      }
    ))
  )
)

(define-public (pay-premium (policy-id uint))
  (let
    ((policy (unwrap! (map-get? insurance-policies { policy-id: policy-id }) (err u404))))
    (asserts! (is-eq tx-sender (get owner policy)) (err u403))
    (asserts! (< block-height (get expiration policy)) (err u400))
    (stx-transfer? (get premium policy) tx-sender CONTRACT_OWNER)
  )
)

(define-public (file-claim (policy-id uint) (claim-amount uint))
  (let
    ((policy (unwrap! (map-get? insurance-policies { policy-id: policy-id }) (err u404))))
    (asserts! (is-eq tx-sender (get owner policy)) (err u403))
    (asserts! (<= block-height (get expiration policy)) (err u400))
    (asserts! (<= claim-amount (get coverage-amount policy)) (err u400))
    (as-contract (stx-transfer? claim-amount CONTRACT_OWNER (get owner policy)))
  )
)

(define-read-only (get-policy-info (policy-id uint))
  (map-get? insurance-policies { policy-id: policy-id })
)

