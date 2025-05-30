//
//  HealthManagementView.swift
//  PregnancyBattle
//
//  Created on 2023/5/12.
//

import SwiftUI

struct HealthManagementView: View {
    @StateObject private var viewModel = HealthManagementViewModel()

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.healthProfile == nil {
                ProgressView("加载中...")
            } else if viewModel.showingCreateForm {
                HealthProfileFormView(
                    viewModel: viewModel,
                    isCreating: true,
                    onSubmit: {
                        Task {
                            await viewModel.createHealthProfile()
                        }
                    },
                    onCancel: {
                        viewModel.showingCreateForm = false
                    }
                )
            } else if viewModel.showingUpdateForm {
                HealthProfileFormView(
                    viewModel: viewModel,
                    isCreating: false,
                    onSubmit: {
                        Task {
                            await viewModel.updateHealthProfile()
                        }
                    },
                    onCancel: {
                        viewModel.showingUpdateForm = false
                    }
                )
            } else if viewModel.showingWeightForm {
                WeightRecordFormView(
                    viewModel: viewModel,
                    onSubmit: {
                        Task {
                            await viewModel.recordDailyWeight()
                        }
                    },
                    onCancel: {
                        viewModel.showingWeightForm = false
                    }
                )
            } else {
                mainContentView
            }
        }
        .navigationTitle("健康管理")
        .alert(isPresented: $viewModel.showingSuccessAlert) {
            Alert(
                title: Text("成功"),
                message: Text(viewModel.successMessage),
                dismissButton: .default(Text("确定"))
            )
        }
        .refreshable {
            await viewModel.loadData()
        }
    }

    private var mainContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 只有在不显示创建表单时才显示错误信息
                if let error = viewModel.error, !viewModel.showingCreateForm {
                    VStack(spacing: 10) {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()

                        Button(action: {
                            Task {
                                await viewModel.loadData()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("重试")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color("hm_color_primary"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }

                if let profile = viewModel.healthProfile {
                    // 健康档案卡片
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("健康档案")
                                .font(.headline)

                            Spacer()

                            Button(action: {
                                viewModel.showingUpdateForm = true
                            }) {
                                Text("编辑")
                                    .font(.subheadline)
                                    .foregroundColor(Color("hm_color_primary"))
                            }
                        }

                        Divider()

                        // 基础信息
                        Group {
                            HStack {
                                Text("身高:")
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", profile.height)) cm")
                                    .fontWeight(.medium)

                                Spacer()

                                Text("年龄:")
                                    .foregroundColor(.secondary)
                                Text("\(profile.age) 岁")
                                    .fontWeight(.medium)
                            }

                            HStack {
                                Text("血型:")
                                    .foregroundColor(.secondary)
                                Text(profile.bloodType)
                                    .fontWeight(.medium)

                                Spacer()

                                Text("BMI:")
                                    .foregroundColor(.secondary)
                                Text(String(format: "%.1f", profile.bmi))
                                    .fontWeight(.medium)
                            }

                            if !profile.medicalHistory.isNilOrEmpty {
                                Text("个人病史: \(profile.medicalHistory ?? "")")
                                    .font(.subheadline)
                            }

                            if !profile.familyHistory.isNilOrEmpty {
                                Text("家族病史: \(profile.familyHistory ?? "")")
                                    .font(.subheadline)
                            }

                            if !profile.allergiesHistory.isNilOrEmpty {
                                Text("过敏史: \(profile.allergiesHistory ?? "")")
                                    .font(.subheadline)
                            }

                            if !profile.obstetricHistory.isNilOrEmpty {
                                Text("既往孕产史: \(profile.obstetricHistory ?? "")")
                                    .font(.subheadline)
                            }

                            HStack {
                                if profile.isSmoking {
                                    Label("吸烟", systemImage: "exclamationmark.triangle")
                                        .foregroundColor(.orange)
                                        .font(.subheadline)
                                }

                                if profile.isDrinking {
                                    Label("饮酒", systemImage: "exclamationmark.triangle")
                                        .foregroundColor(.orange)
                                        .font(.subheadline)
                                }

                                if !profile.isSmoking && !profile.isDrinking {
                                    Label("无不良生活习惯", systemImage: "checkmark.circle")
                                        .foregroundColor(.green)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                    // 体重记录卡片
                    VStack(alignment: .leading, spacing: 10) {
                        Text("体重记录")
                            .font(.headline)

                        HStack {
                            VStack(alignment: .leading) {
                                Text("孕前体重")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", profile.prePregnancyWeight)) kg")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text("当前体重")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", profile.currentWeight)) kg")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text("增长")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", profile.weightGain)) kg")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }

                        Button(action: {
                            viewModel.currentWeight = String(format: "%.1f", profile.currentWeight)
                            viewModel.showingWeightForm = true
                        }) {
                            Text("记录今日体重")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color("hm_color_primary"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                    // 体重趋势图表
                    if let weightTrend = viewModel.weightTrend {
                        WeightTrendChartView(weightTrend: weightTrend, healthProfile: viewModel.healthProfile)
                            .padding(.horizontal)
                    }

                    // 风险评估
                    Group {
                        if viewModel.isLoadingRiskAssessment {
                            RiskAssessmentLoadingView()
                                .padding(.horizontal)
                                .id("loading-\(UUID())")  // 强制刷新
                        } else if let riskAssessment = viewModel.riskAssessment {
                            EnhancedRiskAssessmentView(riskAssessment: riskAssessment)
                                .padding(.horizontal)
                                .id("assessment-\(riskAssessment.isAiEnhanced ? "ai" : "basic")")  // 基于内容生成唯一ID
                                .transition(.opacity.combined(with: .scale))  // 添加过渡动画
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isLoadingRiskAssessment)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.riskAssessment?.isAiEnhanced)
                } else {
                    // 如果没有健康档案，显示创建按钮
                    VStack(spacing: 20) {
                        Text("您还没有创建健康档案")
                            .font(.headline)

                        Button(action: {
                            viewModel.showingCreateForm = true
                        }) {
                            Text("创建健康档案")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color("hm_color_primary"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// 扩展String?，添加isNilOrEmpty属性
extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self == nil || self!.isEmpty
    }
}

#Preview {
    NavigationView {
        HealthManagementView()
    }
}
