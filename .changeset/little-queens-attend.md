---
"evervault-ruby": patch
---

Improved API for configuring the Evervault::Client.

Previously there was no way to set the curve used for encryption. This can now
be configured via the .configure method.

```
Evervault.configure do |config|
  config.curve = "secp256k1"
end
```
