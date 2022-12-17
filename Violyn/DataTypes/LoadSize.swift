//
//  LoadSize.swift
//  Violyn
//
//  Created by Lilliana on 29/11/2022.
//

enum LoadSize {
    case update, quarter, half, three, full
    
    var description: String {
        switch self {
            case .update:
                return "Update"
            case .quarter:
                return "25%"
            case .half:
                return "50%"
            case .three:
                return "75%"
            case .full:
                return "100%"
        }
    }
}
