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
# GENERATED for srelens-v0.15.0 — do not edit by hand.
# Rendered from packaging/homebrew/srelens-tui.rb in srelens/srelens by
# packaging/homebrew/render.mjs, using that release's published SHA256SUMS.
class SrelensTui < Formula
  desc "Kubernetes control room in your terminal, built in Rust with k9s navigation"
  homepage "https://github.com/srelens/srelens"
  version "0.15.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.15.0/srelens-tui-0.15.0-aarch64-apple-darwin.tar.gz"
      sha256 "497380818023b644fe108298652f40b9b6df03593b652e2c1f5d821d8c923438"
    end
    on_intel do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.15.0/srelens-tui-0.15.0-x86_64-apple-darwin.tar.gz"
      sha256 "f645c6c6b54771da8623ffee38756b90dbbeb870daa3a4bd8466817a46ea927c"
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
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.15.0/srelens-tui-0.15.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "f12f1ada2cb29219444bab5845c7883ddb0b4a03ad40bf79809076abf8d86595"
    end
    on_intel do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.15.0/srelens-tui-0.15.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "7ff2ceb8d8e58cf58fbf0d45c007605131e3a44b6ff030a06672b7ffb31eb0ae"
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
