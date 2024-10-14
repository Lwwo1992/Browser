//
//  AboutView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/9.
//

import SwiftUI

struct AboutView: View {
    enum AboutOption: String, CaseIterable {
        case checkForUpdates = "检查版本更新"
        case privacyPolicy = "隐私政策"
        case termsOfService = "服务条款"

        static var sections: [[AboutOption]] {
            [
                [.checkForUpdates],
                [.privacyPolicy, .termsOfService],
            ]
        }
    }

    @State private var isOn: Bool = false

    var body: some View {
        VStack {
            Image(.tomatoBottom)
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .padding(.top, 20)

            Text(Util.appVersion())
                .font(.system(size: 14))
                .opacity(0.5)

            OptionListView(
                sections: AboutOption.sections,
                onTap: handleTap(for:)
            )
            .padding(.top, 40)
        }
        .padding(.horizontal, 16)
    }

    private func handleTap(for item: AboutOption) {
        switch item {
        case .checkForUpdates:
            HUD.showLoading("尚未实现 要得到 YOUR_APP_ID 才能实现")
//            checkAppStoreVersion()
        case .privacyPolicy:
            fetchAgreementContent(requestData: 2, titleText: "隐私协议")
        case .termsOfService:
            fetchAgreementContent(requestData: 3, titleText: "服务协议")
        }
    }

    private func fetchAgreementContent(requestData: Int, titleText: String) {
        HUD.showLoading()
        APIProvider.shared.request(.getConfigByType(data: requestData), model: ConfigByTypeModel.self) { result in
            HUD.hideNow()
            switch result {
            case let .success(model):
                if let content = model.content {
                    let vc = TextDisplayViewController()
                    vc.title = titleText
                    vc.content = content
                    Util.topViewController().navigationController?.pushViewController(vc, animated: true)
                }
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    private func checkAppStoreVersion() {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=YOUR_APP_ID") else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let appStoreVersion = results.first?["version"] as? String {
                    print("App Store Version: \(appStoreVersion)")
                    // 比较版本号
                    self.compareVersions(appStoreVersion)
                }
            } catch {
                print("Failed to parse response: \(error)")
            }
        }
        task.resume()
    }

    private func compareVersions(_ appStoreVersion: String) {
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if currentVersion.compare(appStoreVersion, options: .numeric) == .orderedAscending {
                print("New version available in App Store!")
                DispatchQueue.main.async {
                    self.promptForUpdate()
                }
            }
        }
    }

    private func promptForUpdate() {
        let alertController = UIAlertController(
            title: "更新可用",
            message: "有一个新版本可用，是否更新？",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "更新", style: .default, handler: { _ in
            if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") {
                UIApplication.shared.open(url)
            }
        }))
        alertController.addAction(UIAlertAction(title: "稍后", style: .cancel))
        Util.topViewController().present(alertController, animated: true)
    }
}

#Preview {
    AboutView()
}
