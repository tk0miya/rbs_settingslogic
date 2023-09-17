# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature "sig"
  signature "lib/rbs_settingslogic/sig"

  check "lib"

  configure_code_diagnostics(D::Ruby.lenient)
end
