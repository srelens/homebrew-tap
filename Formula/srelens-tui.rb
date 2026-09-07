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
# GENERATED for srelens-v0.9.0 — do not edit by hand.
# Rendered from packaging/homebrew/srelens-tui.rb in srelens/srelens by
# packaging/homebrew/render.mjs, using that release's published SHA256SUMS.
class SrelensTui < Formula
  desc "Kubernetes control room in your terminal, built in Rust with k9s navigation"
  homepage "https://github.com/srelens/srelens"
  version "0.9.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.9.0/srelens-tui-0.9.0-aarch64-apple-darwin.tar.gz"
      sha256 "5ee7e04dd287eed29151ad1272168e73f02706dd9ac38c2679b45c50fa29e386"
    end
    on_intel do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.9.0/srelens-tui-0.9.0-x86_64-apple-darwin.tar.gz"
      sha256 "de7046cb4d22e72c22632b77b011d47334798381be95d2d0a3f0b37a06553746"
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
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.9.0/srelens-tui-0.9.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "6957a3df2b3e3da25c76464843d769794c429b62bd6802a59cab2fd9aa196079"
    end
    on_intel do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.9.0/srelens-tui-0.9.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "4a9e493b53486b144f5aad8ce8dca6ae760cb5da896f69efc0e74152756a072b"
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
