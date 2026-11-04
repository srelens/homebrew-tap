# srelens — the signed and notarized macOS desktop application.
#
# GENERATED for srelens-v0.17.0 — do not edit by hand.
# Rendered from packaging/homebrew/srelens.rb after hashing both public DMGs.
cask "srelens" do
  arch arm: "aarch64", intel: "x64"

  version "0.17.0"
  sha256 arm:   "390aa3df68e25ba1fd7deb702276704be6644027e23952b8412adbc7780a52e2",
         intel: "fb173fcf99226376c5ee48151a6d0cdf587aa6d9889a9da0005ba4388e24d6e0"

  url "https://github.com/srelens/srelens/releases/download/srelens-v#{version}/srelens_#{version}_#{arch}.dmg"
  name "srelens"
  desc "Kubernetes control room for engineers and AI agents"
  homepage "https://github.com/srelens/srelens"

  auto_updates true
  depends_on :macos

  app "srelens.app"
end
