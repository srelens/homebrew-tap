# srectl — the terminal UI, installed from the prebuilt release archive.
#
# A formula rather than a cask: this is a command-line binary. The desktop app
# is a `.dmg` and wants `brew install --cask` (see #225), which is a separate
# piece of work published a different way.
#
# It installs the archive the release already publishes instead of compiling
# from source. Building srectl pulls in the whole workspace — kube-rs,
# reqwest, ratatui, tokio — for a binary CI has already produced, signed and
# notarized for exactly these four targets. `brew install` should not take
# minutes to do again, worse, what a download does in seconds.
#
# GENERATED for srelens-v0.17.0 — do not edit by hand.
# Rendered from packaging/homebrew/srectl.rb in srelens/srelens by
# packaging/homebrew/render.mjs, using that release's published SHA256SUMS.
class Srectl < Formula
  desc "Kubernetes control room in your terminal, built in Rust with k9s navigation"
  homepage "https://github.com/srelens/srelens"
  version "0.17.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.17.0/srectl-0.17.0-aarch64-apple-darwin.tar.gz"
      sha256 "e866dab12377393857f5ec5f1073327824a04d003e371f8324859e1fc5176f65"
    end
    on_intel do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.17.0/srectl-0.17.0-x86_64-apple-darwin.tar.gz"
      sha256 "ba3a3ebb34521661700bf3e05a1c4383bb9ed51aa749166fac4906d992f017c4"
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
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.17.0/srectl-0.17.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "ea981e10833ce4da2c89a1bdb3277c338f36469f6effc5526027486aa36c7c84"
    end
    on_intel do
      url "https://github.com/srelens/srelens/releases/download/srelens-v0.17.0/srectl-0.17.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "af5b2b7cfc37cf775c92da88ba7e806c8bc23529cf9c60a1bd4b03f02f3cbf28"
    end
  end

  # srelens deliberately does not bundle a toolchain — it drives the kubectl
  # and helm already on the machine, including kubeconfig exec-auth plugins —
  # so these are genuinely optional rather than dependencies.
  def caveats
    <<~EOS
      srectl is the command. srelens-tui still runs it, and prints a one-line
      reminder.

      srectl uses the kubectl and helm already on your PATH, if any.
      Neither is required to browse a cluster; `srectl toolbox` reports
      what it found.

      Homebrew owns this copy, so `srectl update` will decline to replace
      it and point you back here. Use `brew upgrade srectl` instead.
    EOS
  end

  def install
    # The archive holds the binary as `srectl`. Install it, and also
    # leave `srelens-tui` as a wrapper so existing scripts and muscle memory work.
    bin.install "srectl"
    (bin/"srelens-tui").write <<~SH
      #!/bin/sh
      [ -t 2 ] && echo "srelens-tui is now srectl" >&2
      exec "#{bin}/srectl" "$@"
    SH
    chmod 0755, bin/"srelens-tui"
  end

  test do
    # Asserts the binary runs AND that the formula's version matches what was
    # actually packaged — a mismatch means the render step and the release
    # disagree, which is worth failing on.
    assert_match version.to_s, shell_output("#{bin}/srectl --version")

    # The old command name runs the same binary. When stderr is redirected,
    # the wrapper suppresses the reminder so output parsing is not broken.
    version_output = shell_output("#{bin}/srelens-tui --version 2>&1")
    assert_match version.to_s, version_output
    refute_match "srelens-tui is now srectl", version_output

    # A command that needs no cluster, to prove the binary is not merely
    # loadable. With no kubeconfig it reports zero contexts rather than failing.
    assert_match "srectl", shell_output("#{bin}/srectl info")

    # The legacy wrapper also forwards subcommand arguments.
    assert_match "srectl", shell_output("#{bin}/srelens-tui info")
  end
end
