//
//  OperateBottomView.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/18.
//

import SwiftUI

struct OperateBottomView: View {
    @ObservedObject var viewModel: HistoryViewModel
    /// 判断需要 '新建文件夹'
    var showFolder: Bool = true

    var body: some View {
        HStack {
            if viewModel.isEdit {
                editModeButtons()
            } else {
                normalModeButtons()
            }
        }
        .font(.system(size: 14))
        .foregroundColor(.black)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    @ViewBuilder
    private func editModeButtons() -> some View {
        let selectAllButtonTitle: String = {
            if viewModel.selectedSegmentIndex == 0 {
                return (viewModel.isAllSelected && viewModel.isAllFolderSelected) ? "取消全选" : "全选"
            } else {
                return viewModel.isAllSelected ? "取消全选" : "全选"
            }
        }()

        Button(selectAllButtonTitle) {
            if viewModel.selectedSegmentIndex == 0 {
                viewModel.toggleSelectFolderAll()
            }
            viewModel.toggleSelectAll()
        }
        .frame(maxWidth: .infinity)

        Button("删除") {
            if !viewModel.selectedArray.isEmpty || !viewModel.selectedFolderArray.isEmpty {
                viewModel.showingDeleteAlert.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .alert(isPresented: $viewModel.showingDeleteAlert) {
            Alert(
                title: Text("删除"),
                message: Text("您确定要删除选中的吗？"),
                primaryButton: .destructive(Text("删除")) {
                    if viewModel.selectedSegmentIndex == 0 {
                        viewModel.deleteSelectedFolderItems()
                    }
                    viewModel.deleteSelectedItems()
                },
                secondaryButton: .cancel(Text("取消"))
            )
        }

        Button("完成") {
            viewModel.isEdit.toggle()
            if viewModel.selectedSegmentIndex == 0 {
                viewModel.selectedFolderArray.removeAll()
            }
            viewModel.selectedArray.removeAll()
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func normalModeButtons() -> some View {
        if viewModel.selectedSegmentIndex == 0 {
            if showFolder {
                Button("新建文件夹") {
                    viewModel.showingTextFieldAlert.toggle()
                }
                .frame(maxWidth: .infinity)
            }

            if !viewModel.recordData.isEmpty || !viewModel.folderData.isEmpty {
                Button("立即同步") {
                    if LoginManager.shared.info.logintype == "0" {
                        Util.topViewController().navigationController?.pushViewController(LoginViewController(), animated: true)
                    } else {
                        syncBookmark()
                    }
                }
                .frame(maxWidth: .infinity)
            }

        } else {
            Button("清理记录") {
                viewModel.showingDeleteAlert.toggle()
            }
            .frame(maxWidth: .infinity)
        }
        if !viewModel.recordData.isEmpty || !viewModel.folderData.isEmpty {
            Button("编辑") {
                viewModel.isEdit.toggle()
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func syncBookmark() {
        let parameters: [[String: Any]] = createRequestData(folderData: viewModel.folderData, recordData: viewModel.recordData)

        APIProvider.shared.request(.syncBookmark(data: parameters)) { result in
            switch result {
            case let .success(model):
                break
            case let .failure(error):
                print("Request failed with error: \(error)")
            }
        }
    }

    func createRequestData(folderData: [FolderModel], recordData: [HistoryModel]) -> [[String: Any?]] {
        var dataArray: [[String: Any?]] = []

        // 处理 FolderModel 数据
        for folder in folderData {
            var folderDict: [String: Any?] = [
                "id": folder.id,
                "name": folder.name,
                "parentId": "",
                "address": "",
                "icon": "",
                "accountId": "",
                "children": nil,
            ]

            var childrenArray: [[String: Any?]] = []

            // 处理 FolderModel 的 children (HistoryModel)
            for child in folder.children {
                let childDict: [String: Any?] = [
                    "id": child.id,
                    "parentId": folder.id,
                    "name": child.name,
                    "address": child.address ?? "",
                    "icon": "",
                    "accountId": "",
                    "children": nil,
                ]
                childrenArray.append(childDict)
            }

            folderDict["children"] = childrenArray
            dataArray.append(folderDict)
        }

        // 处理单独的 HistoryModel 数据 (非 FolderModel 的 children)
        for record in recordData {
            let recordDict: [String: Any?] = [
                "id": record.id,
                "address": record.address ?? "",
                "name": "",
                "parentId": "",
                "icon": "",
                "accountId": "",
                "children": nil,
            ]
            dataArray.append(recordDict)
        }

        return dataArray
    }
}