class Pympress < Formula
  include Language::Python::Virtualenv

  desc "Simple and powerful dual-screen PDF reader designed for presentations"
  homepage "https://github.com/Cimbali/pympress/"
  url "https://files.pythonhosted.org/packages/58/1e/f8cec6f30f8aa3927ad73d7f5c3ab7fdc77a253ac69689465a3c42abadc1/pympress-1.6.0.tar.gz"
  sha256 "abac4c86be00795a13e06d1c3e426909fbae96ee9b3ef6eb628fa910e844373b"
  license "GPL-2.0"
  head "https://github.com/Cimbali/pympress.git"

  bottle do
    sha256 cellar: :any, big_sur:  "0dace778ed9f1ac2939f6b4c1305a629c4fc256d8768b9658196e90f0819e84e"
    sha256 cellar: :any, catalina: "d730fa081be30bd9dd49fa5f08cf8aa39ac31842fbb8b86423c1bc28db8b616c"
    sha256 cellar: :any, mojave:   "88b035ea21bd93571a1920bd94c1bc293ee68ffbc63237dbe8f9da0958323bae"
  end

  depends_on "gobject-introspection"
  depends_on "gtk+3"
  depends_on "libyaml"
  depends_on "poppler"
  depends_on "pygobject3"
  depends_on "python@3.9"

  resource "watchdog" do
    url "https://files.pythonhosted.org/packages/17/8c/fe6b8554e6a107437375ea6f76c62fbb0deb22288c2eb846c2f92b0d843e/watchdog-2.0.2.tar.gz"
    sha256 "532fedd993e75554671faa36cd04c580ced3fae084254a779afbbd8aaf00566b"
  end

  def install
    virtualenv_install_with_resources
    bin.install_symlink libexec/"bin/pympress"
  end

  test do
    on_linux do
      # (pympress:48790): Gtk-WARNING **: 13:03:37.080: cannot open display
      return if ENV["HOMEBREW_GITHUB_ACTIONS"]
    end

    system bin/"pympress", "--help"

    # Version info contained in log file only if all dependencies loaded successfully
    assert_predicate testpath/"Library/Logs/pympress.log", :exist?
    output = (testpath/"Library/Logs/pympress.log").read
    assert_match(/^INFO:pympress.__main__:Pympress: #{version}\s*;/, output)
  end
end
