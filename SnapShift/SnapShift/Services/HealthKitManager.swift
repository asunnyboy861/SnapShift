import Foundation
import HealthKit
import Combine

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false

    private let weightType = HKQuantityType(.bodyMass)
    private let bodyFatType = HKQuantityType(.bodyFatPercentage)

    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async {
        guard isHealthDataAvailable else { return }

        let types: Set<HKQuantityType> = [weightType, bodyFatType]
        do {
            try await healthStore.requestAuthorization(toShare: [] as Set<HKSampleType>, read: types)
            isAuthorized = true
        } catch {
            print("HealthKit auth error: \(error)")
        }
    }

    func getLatestWeight() async -> Double? {
        guard isAuthorized else { return nil }
        return await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let weight = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: .pound())
                continuation.resume(returning: weight)
            }
            healthStore.execute(query)
        }
    }

    func getLatestBodyFat() async -> Double? {
        guard isAuthorized else { return nil }
        return await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(sampleType: bodyFatType, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let bf = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: .percent())
                continuation.resume(returning: bf.map { $0 * 100 })
            }
            healthStore.execute(query)
        }
    }
}
