import SwiftUI

public struct WeightRecordFormView: View {
    @ObservedObject public var viewModel: HealthManagementViewModel
    public let onSubmit: () -> Void
    public let onCancel: () -> Void

    public init(viewModel: HealthManagementViewModel, onSubmit: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSubmit = onSubmit
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("记录今日体重")) {
                    TextField("体重（千克）", text: $viewModel.currentWeight)
                        .keyboardType(.decimalPad)
                }

                if viewModel.error != nil {
                    Section {
                        Text(viewModel.error!)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button(action: onSubmit) {
                        if viewModel.isRecordingWeight {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("保存")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isRecordingWeight)

                    Button(action: onCancel) {
                        Text("取消")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isRecordingWeight)
                }
            }
            .navigationTitle("体重记录")
        }
    }
}
