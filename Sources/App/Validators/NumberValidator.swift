import Vapor

class NumberValidator: ValidationSuite {
    static func validate(input value: String) throws {
        let range = value.range(of: "^[0-9]*$", options: .regularExpression)
        guard let _ = range else {
            throw error(with: value)
        }
    }
}

