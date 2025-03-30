;; SovereignVote: Decentralized Identity and Voting System
;; A smart contract that combines secure identity management with voting capabilities

;; CivicLink: Decentralized Governance and Identity System
;; A smart contract that combines secure identity management with governance capabilities

;; Constants
(define-constant governance-admin tx-sender)
(define-constant err-admin-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-already-authorized (err u102))
(define-constant err-already-participated (err u103))
(define-constant err-invalid-decision (err u104))
(define-constant err-participation-closed (err u105))
(define-constant err-insufficient-funds (err u106))
(define-constant err-invalid-input (err u107))

;; Data Variables
(define-data-var participation-open bool false)
(define-data-var current-decision-id uint u0)
(define-data-var authorization-fee uint u1000000) ;; 1 STX authorization fee

;; Data Maps
(define-map citizen-profiles
  principal
  {
    verified-status: bool,
    auth-hash: (string-utf8 64),
    onboarding-time: uint
  }
)

(define-map decisions
  uint
  {
    name: (string-utf8 100),
    details: (string-utf8 500),
    support-count: uint,
    oppose-count: uint,
    conclusion-block: uint,
    total-participants: uint
  }
)

(define-map participations
  {decision-id: uint, participant: principal}
  bool
)

;; Private Functions
(define-private (is-authorized (user principal))
  (default-to false (get verified-status (map-get? citizen-profiles user)))
)

(define-private (check-admin)
  (ok (asserts! (is-eq tx-sender governance-admin) err-admin-only))
)

;; Input Validation Functions
(define-private (validate-auth-hash (hash (string-utf8 64)))
  (and 
    (> (len hash) u0)
    (<= (len hash) u64)
  )
)

(define-private (validate-decision-input 
  (name (string-utf8 100)) 
  (details (string-utf8 500))
  (duration uint)
)
  (and
    (> (len name) u0)
    (<= (len name) u100)
    (> (len details) u0)
    (<= (len details) u500)
    (> duration u0)
    (<= duration u52560) ;; Max 1 year in blocks
  )
)

;; Public Functions
(define-public (create-profile (auth-hash (string-utf8 64)))
  (let 
    (
      (fee (var-get authorization-fee))
    )
    (asserts! (validate-auth-hash auth-hash) err-invalid-input)
    (asserts! (not (is-authorized tx-sender)) err-already-authorized)
    (asserts! (>= (stx-get-balance tx-sender) fee) err-insufficient-funds)
    
    ;; Transfer authorization fee to contract admin
    (try! (stx-transfer? fee tx-sender governance-admin))
    
    (ok (map-set citizen-profiles
      tx-sender
      {
        verified-status: true,
        auth-hash: auth-hash,
        onboarding-time: block-height
      }
    ))
  )
)

(define-public (propose-decision 
  (name (string-utf8 100)) 
  (details (string-utf8 500)) 
  (duration uint)
)
  (let
    (
      (decision-id (+ (var-get current-decision-id) u1))
    )
    (asserts! (validate-decision-input name details duration) err-invalid-input)
    (try! (check-admin))
    (map-set decisions
      decision-id
      {
        name: name,
        details: details,
        support-count: u0,
        oppose-count: u0,
        conclusion-block: (+ block-height duration),
        total-participants: u0
      }
    )
    (var-set current-decision-id decision-id)
    (var-set participation-open true)
    (ok decision-id)
  )
)

(define-public (submit-opinion (decision-id uint) (support bool))
  (let
    (
      (decision (unwrap! (map-get? decisions decision-id) err-invalid-decision))
      (participation-key {decision-id: decision-id, participant: tx-sender})
      (current-total-participants (get total-participants decision))
    )
    (asserts! (is-authorized tx-sender) err-not-authorized)
    (asserts! (< block-height (get conclusion-block decision)) err-participation-closed)
    (asserts! (not (default-to false (map-get? participations participation-key))) err-already-participated)
    
    (map-set participations participation-key true)
    (if support
      (map-set decisions decision-id 
        (merge decision 
          {
            support-count: (+ (get support-count decision) u1),
            total-participants: (+ current-total-participants u1)
          }
        )
      )
      (map-set decisions decision-id 
        (merge decision 
          {
            oppose-count: (+ (get oppose-count decision) u1),
            total-participants: (+ current-total-participants u1)
          }
        )
      )
    )
    (ok true)
  )
)

;; Administrative Functions
(define-public (update-authorization-fee (new-fee uint))
  (begin
    (try! (check-admin))
    (asserts! (> new-fee u0) err-invalid-input)
    (var-set authorization-fee new-fee)
    (ok true)
  )
)

;; Read-Only Functions
(define-read-only (get-decision (decision-id uint))
  (map-get? decisions decision-id)
)

(define-read-only (get-citizen-profile (user principal))
  (map-get? citizen-profiles user)
)

(define-read-only (has-participated (decision-id uint) (user principal))
  (default-to false (map-get? participations {decision-id: decision-id, participant: user}))
)

(define-read-only (get-decision-results (decision-id uint))
  (map-get? decisions decision-id)
)

(define-read-only (get-authorization-fee)
  (var-get authorization-fee)
)