//
//  ChomikAPI.swift
//  Violyn
//
//  Created by Lilliana on 01/12/2022.
//

enum ChomikAPI: String {
    case delete = "https://chomikuj.pl/action/FileDetails/DeleteFileAction"
    case download = "https://chomikuj.pl/action/License/Download"
    case files = "https://chomikuj.pl/farato/Dokumenty/debfiles"
    case login = "https://chomikuj.pl/action/login/login/login"
    case search = "https://chomikuj.pl/action/Files/FilesList"
    case upload = "https://chomikuj.pl/action/Upload/GetUrl"
}
