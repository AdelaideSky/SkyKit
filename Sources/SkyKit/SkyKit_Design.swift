import SwiftUI

@available(iOS 17, macOS 14, macCatalyst 17, tvOS 17, visionOS 1, *)
@dynamicMemberLookup
public enum SkyKitShaders {
    /// Returns a new shader function representing the stitchable MSL
    /// function called `name` in the Inferno shader library.
    ///
    /// Typically this subscript is used implicitly via the dynamic
    /// member syntax, for example:
    ///
    ///    let fn = InfernoShaderLibrary.myFunction
    ///
    /// which creates a reference to the MSL function called
    /// `myFunction()`.
    public static subscript(dynamicMember name: String) -> ShaderFunction {
        ShaderLibrary.bundle(.module)[dynamicMember: name]
    }
}
