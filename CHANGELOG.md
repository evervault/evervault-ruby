# evervault-ruby

## 3.0.0

### Major Changes

- f4d3d01: Simplifying errors thrown by the SDK.

  Previously we exposed many different error types for users to handle, but in most cases these errors were not something that could be caught and handled, but were rather indicative of a larger configuration issue. This change simplifies the errors thrown by returning an EvervaultError with accompanying error message by default, unless they are a transient error which can be handled programmatically, in which case a specific error is returned.

- dd84f66: We have dropped support for Ruby 2.6 and 2.7 as they are now both in end of life status.
  See more: https://www.ruby-lang.org/en/downloads/branches
- b2188aa: Migrated Function run requests to new API.

  We have released a new API for Function run requests which is more robust, more extensible, and which provides more useful error messages when Function runs fail. In addition, we have removed async Function run requests and specifying the version of the Function to run. For more details check out https://docs.evervault.com/sdks/ruby#run()

### Minor Changes

- b7f5c1a: The `encrypt` function has been enhanced to accept an optional Data Role.

  This role, once specified, is associated with the data upon encryption. Data Roles can be created in the Evervault Dashboard (Data Roles section) and provide a mechanism for setting clear rules that dictate how and when data, tagged with that role, can be decrypted. For more details check out https://docs.evervault.com/sdks/ruby#encrypt()

  Evervault.encrypt("hello world!", "allow-all");

### Patch Changes

- 7d91003: Add Faraday as a gem dependency
