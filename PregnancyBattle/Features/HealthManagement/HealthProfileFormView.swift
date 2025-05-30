import SwiftUI

public struct HealthProfileFormView: View {
    @ObservedObject public var viewModel: HealthManagementViewModel
    public let isCreating: Bool
    public let onSubmit: () -> Void
    public let onCancel: () -> Void

    public init(viewModel: HealthManagementViewModel, isCreating: Bool, onSubmit: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.viewModel = viewModel
        self.isCreating = isCreating
        self.onSubmit = onSubmit
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基础信息")) {
                    TextField("身高（厘米）", text: $viewModel.height)
                        .keyboardType(.decimalPad)

                    TextField("孕前体重（千克）", text: $viewModel.prePregnancyWeight)
                        .keyboardType(.decimalPad)

                    TextField("当前体重（千克）", text: $viewModel.currentWeight)
                        .keyboardType(.decimalPad)

                    Picker("血型", selection: $viewModel.bloodType) {
                        ForEach(BloodType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    if isCreating {
                        TextField("年龄", text: $viewModel.age)
                            .keyboardType(.numberPad)
                    }
                }

                Section(header: Text("病史")) {
                    TextField("个人病史", text: $viewModel.medicalHistory)
                    TextField("家族病史", text: $viewModel.familyHistory)
                    TextField("过敏史", text: $viewModel.allergiesHistory)
                    TextField("既往孕产史", text: $viewModel.obstetricHistory)
                }

                Section(header: Text("生活习惯")) {
                    Toggle("吸烟", isOn: $viewModel.isSmoking)
                    Toggle("饮酒", isOn: $viewModel.isDrinking)
                }

                if viewModel.error != nil {
                    Section {
                        Text(viewModel.error!)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button(action: onSubmit) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text(isCreating ? "创建" : "更新")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(viewModel.isLoading)

                    Button(action: onCancel) {
                        Text("取消")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle(isCreating ? "创建健康档案" : "更新健康档案")
        }
    }
}
