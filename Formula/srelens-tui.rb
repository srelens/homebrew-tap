# srelens-tui — the terminal UI, installed from the prebuilt release archive.
#
# A formula rather than a cask: this is a command-line binary. The desktop app
# is a `.dmg` and wants `brew install --cask` (see #225), which is a separate
# piece of work published a different way.
#
# It installs the archive the release already publishes instead of compiling
# from source. Building srelens-tui pulls in the whole workspace — kube-rs,
# reqwest, ratatui, tokio — for a binary CI has already produced, signed and
# notarized for exactly these four targets. `brew install` should not take
# minutes to do again, worse, what a download does in seconds.
#
# GENERATED for srelens-v0.12.0 — do not edit by hand.
# Rendered from packaging/homebrew/srelens-tui.rb in srelens/srelens by
# packaging/homebrew/render.mjs, using that release's published SHA256SUMS.
class SrelensTui < Formula
  desc "Kubernetes control room in your terminal, built in Rust with k9s navigation"
  homepage "https://github.com/srelens/srelens"
  version "0.12.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.12.0/srelens-tui-0.12.0-aarch64-apple-darwin.tar.gz"
      sha256 "c33937414b62248063116383a7be99e5e9497f64c0bcbe9e363fca996ab01779"
    end
    on_intel do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.12.0/srelens-tui-0.12.0-x86_64-apple-darwin.tar.gz"
      sha256 "24a7f82da34a1d0bc337160b2d3b6507315d27031b9c4ea9dbda6a71c50d3ff8"
    end
  end

  # Homebrew runs on Linux too, and takes the STATIC musl archives there.
  #
  # Not the glibc ones, which is what this said first and was wrong about.
  # Those are built on ubuntu-22.04 and ubuntu-24.04-arm, so they carry a
  # glibc floor of 2.35 and 2.39 — and Homebrew on Linux deliberately
  # supports far older distributions than that, going as far as building
  # its own glibc when the host's is too old. A dynamically linked binary
  # would then fail before `main` with a GLIBC_2.3x symbol error, which
  # tells the user nothing about what to do.
  #
  # The static builds have no such floor. Their known costs — musl's
  # slower allocator, its narrower resolver — do not matter for a terminal
  # client that spends its time waiting on an API server.
  on_linux do
    on_arm do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.12.0/srelens-tui-0.12.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "3d160f3b6ebe1a008a31a1d30855ab25ee16a3c5ed42e32df84b882fabd75c78"
    end
    on_intel do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.12.0/srelens-tui-0.12.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "412b94233c364a030aae656cd64657501f24015200206ac1ede51ce19db150f1"
    end
  end

  # srelens deliberately does not bundle a toolchain — it drives the kubectl
  # and helm already on the machine, including kubeconfig exec-auth plugins —
  # so these are genuinely optional rather than dependencies.
  def caveats
    <<~EOS
      srelens-tui uses the kubectl and helm already on your PATH, if any.
      Neither is required to browse a cluster; `srelens-tui toolbox` reports
      what it found.

      Homebrew owns this copy, so `srelens-tui update` will decline to replace
      it and point you back here. Use `brew upgrade srelens-tui` instead.
    EOS
  end

  def install
    # The archive holds the binary and LICENSE at its root.
    bin.install "srelens-tui"
  end

  test do
    # Asserts the binary runs AND that the formula's version matches what was
    # actually packaged — a mismatch means the render step and the release
    # disagree, which is worth failing on.
    assert_match version.to_s, shell_output("#{bin}/srelens-tui --version")

    # A command that needs no cluster, to prove the binary is not merely
    # loadable. With no kubeconfig it reports zero contexts rather than failing.
    assert_match "SRElens Kubernetes TUI", shell_output("#{bin}/srelens-tui info")
  end
end
