//
//  Environments.swift
//
//  Created by Alejandro Pasccon on 4/20/17.
//  Copyright © 2017 Alejandro Pasccon. All rights reserved.
//

import Foundation

enum Environment: String {
    case dev = "dev"
    case staging = "staging"
    case production = "production"
}

enum EnvironmentError: Error {
    case malformedFile(String)
    case fileNotFound(String)
}

enum EnvironmentSettings: String {
    case groupTitle = "Build"
    case environmentTitle = "Environment"
    case environmentKey = "environment"
}

class Environments {
    
    static let global = Environments()
    
    fileprivate var currentEnvironment: Environment = .dev
    
    fileprivate var values: [String: Any] = [:]
    
    fileprivate var settingsJson: [String: Any] {
        get {
            let settings = "{\"values\":[{\"Type\":\"PSGroupSpecifier\",\"Title\":\"\(EnvironmentSettings.groupTitle.rawValue)\"},{\"Titles\":[\"Development\",\"Staging\",\"Production\"],\"DefaultValue\":\"\(Environment.dev.rawValue)\",\"Values\":[\"\(Environment.dev.rawValue)\",\"\(Environment.staging.rawValue)\",\"\(Environment.production.rawValue)\"],\"Key\":\"\(EnvironmentSettings.environmentKey.rawValue)\",\"Type\":\"PSMultiValueSpecifier\",\"Title\":\"\(EnvironmentSettings.environmentTitle.rawValue)\"}]}"
            
            let data = settings.data(using: .utf8)
            return (try! JSONSerialization.jsonObject(with: data!, options: [])) as! [String: Any]
        }
        
    }
    
    fileprivate init() {
        // Private initialization to ensure just one instance is created.
    }
    
    fileprivate func processFile(_ fileName: String) throws {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "plist") {
            if let myDict = NSDictionary(contentsOf: url) as? [String:Any] {
                guard myDict[Environment.dev.rawValue] != nil,
                    myDict[Environment.staging.rawValue] != nil,
                    myDict[Environment.production.rawValue] != nil,
                    myDict[currentEnvironment.rawValue] as? [String : Any] != nil else {
                        throw EnvironmentError.malformedFile("The file doesn't match the expected format. Please double check that your file contains exactly the same keys than EnvironmentError enum values.")
                }
                
                values = myDict[currentEnvironment.rawValue] as! [String:Any]
            } else {
                throw EnvironmentError.malformedFile("The file doesn't match the expected format. It must have a dictionary for each available environment.")
            }
        } else {
            throw EnvironmentError.fileNotFound("\(fileName).plist file not found.")
        }
    }
    
    /// Use this configuration method in AppDelegate for example in order to setup the
    /// environment you want to use.
    func configure(with env: Environment, plistFileName: String? = "Environments") throws {
        do {
            if let buildConfiguration = Bundle.main.object(forInfoDictionaryKey: "BSFBuildConfiguration") as? String,
                buildConfiguration == "Release" {
                currentEnvironment = .production
            } else {
                currentEnvironment = env
            }

            try processFile(plistFileName!)
            
            hideInAppSettings()
        }
        catch {
            throw error
        }
    }
    
    /// Use this configuration method if your app has a Settings Bundle
    /// In this case a new "Build" configuration will appear in the app's settings
    /// allowing the user to pick an environment from the list
    func configureBasedOnSettings(plistFileName: String? = "Environments") throws {
        do {
            if let buildConfiguration = Bundle.main.object(forInfoDictionaryKey: "BSFBuildConfiguration") as? String,
                buildConfiguration == "Release" {
                currentEnvironment = .production
                hideInAppSettings()
            } else {
                if let value = UserDefaults.standard.string(forKey: EnvironmentSettings.environmentKey.rawValue),
                    let newEnv = Environment(rawValue: value) {
                    currentEnvironment = newEnv
                } else {
                    currentEnvironment = .dev
                }
            }
            
            try processFile(plistFileName!)
            
            showInAppSettings()
        }
        catch {
            throw error
        }
    }
    
    func value(forKey key: String) -> Any? {
        return values[key]
    }
    
    func showInAppSettings() {
        if !areSettingsShown() {
            if let path = settingsBundlePath() {
                if let plist = settingsAsMutableDictionary() {
                    if let items = plist["PreferenceSpecifiers"] as? NSMutableArray {
                        
                        items.addObjects(from: settingsJson["values"] as! [Any])
                        
                        plist["PreferenceSpecifiers"] = items
                        
                        plist.write(toFile: path, atomically: true)
                        
                    }
                }
            }
        }
    }

    func hideInAppSettings() {
        if areSettingsShown() {
            if let path = settingsBundlePath() {
                if let plist = settingsAsMutableDictionary() {
                    if var items = plist["PreferenceSpecifiers"] as? [NSDictionary] {
                        
                        if let indexForBuild = items.index(where: { $0["Title"] as? String == EnvironmentSettings.groupTitle.rawValue }),
                            let indexForEnvironments = items.index(where: { $0["Title"] as? String == EnvironmentSettings.environmentTitle.rawValue }) {
                            
                            items.remove(at: indexForBuild)
                            items.remove(at: indexForEnvironments)

                            plist["PreferenceSpecifiers"] = items
                            plist.write(toFile: path, atomically: true)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func settingsAsDictionary() -> [String: Any]? {
        if let path = settingsBundlePath() {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let plist = (try? PropertyListSerialization.propertyList(from:data, options: [], format: nil)) as? [String:Any] {
                    return plist
                }
            }
        }

        return nil
    }
    
    fileprivate func settingsAsMutableDictionary() -> NSMutableDictionary? {
        if let path = settingsBundlePath() {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                if let plist = (try? PropertyListSerialization.propertyList(from:data, options: .mutableContainers, format: nil)) as? NSMutableDictionary {
                    return plist
                }
            }
        }
        
        return nil
    }
    
    fileprivate func settingsBundlePath() -> String? {
        if let bundlePath = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath),
            let path = bundle.path(forResource: "Root", ofType: "plist") {
            
            return path
        }
        
        return nil
    }

    
    fileprivate func areSettingsShown() -> Bool {
        if let settings = settingsAsDictionary() {
            if let preferences = settings["PreferenceSpecifiers"] as? [[String: Any]] {
                var containsBuildItem = false
                var containsEnvironmentItem = false

                for preference in preferences {
                    if preference["Title"] as? String == EnvironmentSettings.groupTitle.rawValue {
                        containsBuildItem = true
                    }
                    if preference["Title"] as? String == EnvironmentSettings.environmentTitle.rawValue {
                        containsEnvironmentItem = true
                    }
                }
                
                return containsBuildItem && containsEnvironmentItem
            }
            
        }
        
        return false
    }
}
