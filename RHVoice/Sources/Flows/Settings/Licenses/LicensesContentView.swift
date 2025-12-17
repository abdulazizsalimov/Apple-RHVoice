//
//  LicensesContentView.swift
//  RHVoiceApp
//
//  Created by Ihor Shevchuk on 05.01.2023.
//
//  Copyright (C) 2022–2024 Ihor Shevchuk
//  Copyright (C) 2025 Non-Routine LLC
//  Contact: contact@nonroutine.com
//
//  SPDX-License-Identifier: GPL-3.0-or-later
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI

struct LicensesContentView: View {
    
    @StateObject var hostModel: LicensesHostModel
    
    var body: some View {
        List {
            ForEach(hostModel.viewModel.licenses, id: \.self) { license in
                NavigationLink {
                    List {
                        Text(license.content)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .navigationTitle(license.name)
#if !os(macOS)
                    .navigationBarTitleDisplayMode(.inline)
#endif
                } label: {
                    Text(license.name)
                }
            }
        }
        .navigationTitle(Text("ios_licenses".localized))
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

#if DEBUG
struct LicensesContentView_Previews: PreviewProvider {
    static var previews: some View {
        LicensesContentView(hostModel: LicensesHostModel())
    }
}
#endif
