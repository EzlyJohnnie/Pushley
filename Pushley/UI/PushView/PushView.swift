//
//  PushView.swift
//  Pushley
//
//  Created by Johnnie Cheng on 6/3/20.
//  Copyright © 2020 Johnnie Cheng. All rights reserved.
//

import SwiftUI

struct PushView<ViewModel: PushViewModelProtocol>: View {
    
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Certificate: ")
                if viewModel.certificate != nil {
                    Text(viewModel.certificate!.label)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.top, 5)
                        .padding(.bottom, 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0), lineWidth: 1)
                        )
                }
                Button(
                    action:{ self.viewModel.showCertificatePicker() },
                    label: { Text("Select...") }
                )
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 45) {
                Picker("Environment:", selection: self.$viewModel.environment) {
                    Text("Production").tag(Environment.production)
                    Text("Sandbox").tag(Environment.sandbox)
                }
                .frame(maxWidth: 350)
                .pickerStyle(SegmentedPickerStyle())
                
                Picker("Push Type: ", selection: self.$viewModel.pushType) {
                    Text(PushType.alert.rawValue).tag(PushType.alert)
                    Text(PushType.background.rawValue).tag(PushType.background)
                    Text(PushType.voip.rawValue).tag(PushType.voip)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Spacer()
            }
            .padding(.bottom, 10)
            
            HStack(alignment: .center, spacing: 30) {
                Checkbox(label: "content-available", isChecked: $viewModel.contentAvailable)
                    .fixedSize()
                
                Checkbox(label: "mutable-content", isChecked: $viewModel.mutableContent)
                    .fixedSize()
            }
            .padding(.bottom, 10)
            
            HStack(alignment: .center) {
                Text("Title:")
                TextField("", text: self.$viewModel.notificationTitle)
                    .cornerRadius(5)
                    .focusable()
            }
            
            HStack(alignment: .center) {
                Text("Body:")
                TextField("", text: self.$viewModel.notificationBody)
                    .cornerRadius(5)
                    .focusable()
            }
            
            HStack(alignment: .center) {
                Text("Device Token:")
                TextField("", text: self.$viewModel.deviceToken)
                    .cornerRadius(5)
                    .focusable()
            }
            .padding(.bottom, 15)
            
//            HStack(alignment: .center) {
//                Text("Extra Data JSON:")
//                TextField("", text: self.$viewModel.extraDataJSON)
//                    .cornerRadius(5)
//                    .focusable()
//            }
//            .padding(.bottom, 15)
            
            ZStack(alignment: .bottomTrailing) {
                NSScrollableTextViewWrapper(text: self.$viewModel.log)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(5)
                
                Button(action: { self.viewModel.clearLog() }) {
                    Image(nsImage: NSImage(named: NSImage.refreshTemplateName) ?? NSImage())
                }
                    .frame(width: 40, height: 40)
                    .buttonStyle(SimpleButtonStyle())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            HStack(alignment: .center) {
                Button(action: {
                    self.viewModel.resetIfNeeded()
                }) { Text("Reset") }
                    .buttonStyle(SimpleButtonStyle(style: .blue))
                Spacer()
                Button(action: {
                    self.viewModel.send()
                }) { Text("Send") }
            }
        }
        .padding(10)
        .frame(minWidth: 600, maxWidth: .infinity,
               minHeight: 400, maxHeight: .infinity)
    }
    
}

struct PushView_Previews: PreviewProvider {
    
    static var previews: some View {
        PushView(viewModel: DIContainer.shared.injectPushViewModel())
    }
    
}
