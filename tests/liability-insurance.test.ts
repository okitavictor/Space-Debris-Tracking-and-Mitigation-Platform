import { describe, it, beforeEach, expect } from "vitest"

describe("Liability and Insurance Contract", () => {
  let mockStorage: Map<string, any>
  let nextPolicyId: number
  let currentBlockHeight: number
  const CONTRACT_OWNER = "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM"
  
  beforeEach(() => {
    mockStorage = new Map()
    nextPolicyId = 0
    currentBlockHeight = 0
  })
  
  const mockContractCall = (method: string, args: any[], sender: string) => {
    switch (method) {
      case "create-policy":
        const [coverageAmount, premium, duration] = args
        nextPolicyId++
        mockStorage.set(`policy-${nextPolicyId}`, {
          owner: sender,
          coverage_amount: coverageAmount,
          premium: premium,
          expiration: currentBlockHeight + duration,
        })
        return { success: true, value: nextPolicyId }
      
      case "pay-premium":
        const [payPolicyId] = args
        const payPolicy = mockStorage.get(`policy-${payPolicyId}`)
        if (!payPolicy) return { success: false, error: 404 }
        if (payPolicy.owner !== sender) return { success: false, error: 403 }
        if (currentBlockHeight >= payPolicy.expiration) return { success: false, error: 400 }
        // Simulating STX transfer
        return { success: true }
      
      case "file-claim":
        const [claimPolicyId, claimAmount] = args
        const claimPolicy = mockStorage.get(`policy-${claimPolicyId}`)
        if (!claimPolicy) return { success: false, error: 404 }
        if (claimPolicy.owner !== sender) return { success: false, error: 403 }
        if (currentBlockHeight > claimPolicy.expiration) return { success: false, error: 400 }
        if (claimAmount > claimPolicy.coverage_amount) return { success: false, error: 400 }
        // Simulating STX transfer
        return { success: true }
      
      case "get-policy-info":
        return { success: true, value: mockStorage.get(`policy-${args[0]}`) }
      
      default:
        return { success: false, error: "Unknown method" }
    }
  }
  
  it("should create a policy", () => {
    const result = mockContractCall("create-policy", [1000000, 50000, 52560], "user1")
    expect(result.success).toBe(true)
    expect(result.value).toBe(1)
  })
  
  it("should pay premium", () => {
    mockContractCall("create-policy", [1000000, 50000, 52560], "user1")
    const result = mockContractCall("pay-premium", [1], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should not pay premium if not policy owner", () => {
    mockContractCall("create-policy", [1000000, 50000, 52560], "user1")
    const result = mockContractCall("pay-premium", [1], "user2")
    expect(result.success).toBe(false)
    expect(result.error).toBe(403)
  })
  
  it("should file claim", () => {
    mockContractCall("create-policy", [1000000, 50000, 52560], "user1")
    const result = mockContractCall("file-claim", [1, 500000], "user1")
    expect(result.success).toBe(true)
  })
  
  it("should not file claim if amount exceeds coverage", () => {
    mockContractCall("create-policy", [1000000, 50000, 52560], "user1")
    const result = mockContractCall("file-claim", [1, 1500000], "user1")
    expect(result.success).toBe(false)
    expect(result.error).toBe(400)
  })
  
  it("should get policy info", () => {
    mockContractCall("create-policy", [1000000, 50000, 52560], "user1")
    const result = mockContractCall("get-policy-info", [1], "anyone")
    expect(result.success).toBe(true)
    expect(result.value).toEqual({
      owner: "user1",
      coverage_amount: 1000000,
      premium: 50000,
      expiration: 52560,
    })
  })
})

