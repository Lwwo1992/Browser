//
//  OperateBottomView.swift
//  Browser
//
//  Created by xyxy on 2024/10/18.
//

import SwiftUI

struct OperateBottomView: View {
    @EnvironmentObject var viewModel: HistoryViewModel
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

                if !viewModel.recordData.isEmpty || !viewModel.folderData.isEmpty {
                    HStack(spacing: 2) {
                        Button("立即同步") {
                            S.Config.lastSyncTime = Date()
                            viewModel.syncBookmark()
                        }
                        if S.Config.lastSyncTimeAgo().count > 0 {
                            Text("(\(S.Config.lastSyncTimeAgo()))")
                                .font(.system(size: 10))
                                .opacity(0.5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

        } else {
            Button("清理记录") {
                viewModel.showingAllDeleteAlert.toggle()
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
}
