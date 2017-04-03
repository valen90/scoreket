import Vapor

class DateValidator: ValidationSuite {
    static func validate(input value: String) throws {
        let range = value.range(of: "^[0-9]*$", options: .regularExpression)
        guard let _ = range else {
            throw error(with: "A number was expected '"+value+"' found")
        }
    }
}

