import Vapor

public struct AutoMigrator {
    
    let app: Application
    
    public init(app: Application) {
        self.app = app
    }
}
